# Initialize ExUnit with standard 60s timeout
ExUnit.start(max_cases: 1)

# =============================================================================
# MANAGED SERVICE: SystemTestingUIAutomation.Manager
# =============================================================================
defmodule SystemTestingUIAutomation.Manager do
  @moduledoc """
  Orchestrates UI testing infrastructure.
  Handles synchronized logging, video compression (medium preset), 
  and full path reporting.
  """

  def start_env(config) do
    IO.puts("🚀 [System] Initializing System Testing UI Automation...")
    Process.flag(:trap_exit, true)

    File.mkdir_p!(config.runtime_dir)
    File.chmod!(config.runtime_dir, 0o700)

    final_video = String.replace(config.video_file, Path.extname(config.video_file), "_final.mp4")
    
    # Clean up previous runs
    Enum.each([config.log_file, config.video_file, final_video], fn f ->
      if File.exists?(f), do: File.rm!(f)
    end)

    System.put_env([
      {"XDG_RUNTIME_DIR", config.runtime_dir},
      {"WLR_BACKENDS", "headless"},
      {"WLR_LIBINPUT_NO_DEVICES", "1"},
      {"WAYLAND_DISPLAY", "wayland-0"}
    ])

    apps = [
      {"COMPOSITOR", "cage -s -- env -u WAYLAND_DISPLAY looking-glass-client win:size=1920x1080 win:fullScreen=yes -s -f /dev/shm/looking-glass"},
      {"RECORDER", "wf-recorder -f #{config.video_file}"}
    ]

    log_handle = File.open!(config.log_file, [:append, :utf8])
    aggregator_pid = spawn_link(fn -> log_collector(%{}, log_handle) end)

    ports = Enum.map(apps, fn {label, cmd} ->
      port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
      
      send(aggregator_pid, {:register, port, label, self()})
      receive do: ({:registered, ^port} -> :ok)
      
      Port.connect(port, aggregator_pid)
      {port, label}
    end)

    case wait_for_log(config.log_file, "Starting session", 15) do
      :ok ->
        {:ok, %{ports: ports, log_handle: log_handle, aggregator_pid: aggregator_pid, config: config}}
      :error ->
        {:error, "Infrastructure failed to stabilize."}
    end
  end

  def stop_env(state) do
    IO.puts("\n\n🧹 [System] Initiating Teardown...")

    System.cmd("pkill", ["-f", "-INT", "wf-recorder"])
    System.cmd("pkill", ["-f", "-15", "cage"])
    System.cmd("pkill", ["-f", "-15", "looking-glass-client"])

    wait_for_ports_exit(state.ports)

    # Compression (Logs to file, deletes MKV on success)
    run_managed_compression(state, "COMPRESSION")

    if Process.alive?(state.aggregator_pid) do
      ref = Process.monitor(state.aggregator_pid)
      send(state.aggregator_pid, :stop)
      receive do
        {:DOWN, ^ref, :process, _pid, _reason} -> :ok
      after
        5000 -> IO.puts("⚠️ [System] Log synchronization timeout.")
      end
    end

    File.close(state.log_handle)
    if File.exists?(state.config.runtime_dir), do: File.rm_rf!(state.config.runtime_dir)
    print_report(state.config)
  end

  defp run_managed_compression(state, label) do
    in_path = state.config.video_file
    if File.exists?(in_path) do
      out_path = String.replace(in_path, Path.extname(in_path), "_final.mp4")
      IO.puts("🗜️  [System] Compressing video (Balanced 'medium' preset)...")

      args = ["-nostats", "-loglevel", "info", "-i", in_path, "-vcodec", "libx264", "-preset", "medium", "-crf", "23", "-threads", "0", "-y", out_path]
      cmd = "ffmpeg " <> Enum.join(args, " ")
      
      port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
      
      send(state.aggregator_pid, {:register, port, label, self()})
      receive do: ({:registered, ^port} -> :ok)
      
      Port.connect(port, state.aggregator_pid)

      receive do
        {:port_exit, ^label, 0} ->
          case File.stat(out_path) do
            {:ok, %File.Stat{size: size}} when size > 0 ->
              File.rm!(in_path)
              IO.puts("✅ [System] Compression successful. MKV removed.")
            _ ->
              raise "Compression error: Final MP4 is missing or 0 bytes."
          end

        {:port_exit, ^label, code} ->
          raise "Compression error: FFmpeg exited with code #{code}."

      after
        180_000 ->
          try do Port.close(port) rescue _ -> :ok end
          raise "Compression error: Timeout reached after 180s."
      end
    end
  end

  defp log_collector(port_map, log_handle) do
    receive do
      {:register, port, label, caller_pid} ->
        send(caller_pid, {:registered, port})
        log_collector(Map.put(port_map, port, {label, caller_pid}), log_handle)

      {port, {:data, msg}} ->
        {label, _} = Map.get(port_map, port, {"UNKNOWN", nil})
        write_to_file(label, msg, log_handle)
        log_collector(port_map, log_handle)

      {port, {:exit_status, status}} ->
        {label, pid} = Map.get(port_map, port, {"UNKNOWN", nil})
        if pid, do: send(pid, {:port_exit, label, status})
        log_collector(Map.delete(port_map, port), log_handle)

      :stop ->
        drain_mailbox(port_map, log_handle)
    end
  end

  defp drain_mailbox(port_map, handle) do
    receive do
      {port, {:data, msg}} ->
        {label, _} = Map.get(port_map, port, {"DRAIN", nil})
        write_to_file(label, msg, handle)
        drain_mailbox(port_map, handle)
    after
      1000 -> :ok
    end
  end

  defp write_to_file(label, msg, handle) do
    ts = DateTime.utc_now() |> DateTime.to_string()
    formatted = msg
                |> String.split("\n", trim: true)
                |> Enum.map_join(&("[#{ts}] [#{label}] #{&1}\n"))
    try do
      IO.write(handle, formatted)
      :file.datasync(handle)
    rescue
      _ -> :ok
    end
  end

  defp wait_for_ports_exit(ports) do
    receive do
      {_p, {:exit_status, _}} -> wait_for_ports_exit(ports)
    after
      2000 -> :ok
    end
  end

  defp wait_for_log(file, pattern, attempts) when attempts > 0 do
    if File.exists?(file) and String.contains?(File.read!(file), pattern), do: :ok, else: (Process.sleep(1000); wait_for_log(file, pattern, attempts - 1))
  end
  defp wait_for_log(_, _, _), do: :error

  defp print_report(config) do
    final_path = Path.expand(String.replace(config.video_file, Path.extname(config.video_file), "_final.mp4"))
    log_path = Path.expand(config.log_file)
    
    IO.puts("\n" <> String.duplicate("=", 70))
    IO.puts("🏁 [System] Automation Suite Finished.")
    IO.puts("📽️  Play Video: mpv --autofit=100%x100% #{final_path}")
    IO.puts("📝 Full Log Path: #{log_path}")
    IO.puts(String.duplicate("=", 70))
  end
end

# =============================================================================
# TEST SUITE
# =============================================================================
defmodule SystemTestingUIAutomation.Test do
  use ExUnit.Case, async: false
  alias SystemTestingUIAutomation.Manager

  @config %{
    log_file: "system_testing.log",
    video_file: "./system_testing.mkv",
    runtime_dir: "/tmp/system_testing_runtime"
  }

  setup_all do
    case Manager.start_env(@config) do
      {:ok, state} ->
        on_exit(fn ->
          Manager.stop_env(state)
          System.halt(0)
        end)
        {:ok, state: state}
      {:error, reason} ->
        flunk("Infrastructure error: #{reason}")
    end
  end

  test "capture UI interaction", _context do
    IO.puts("🧪 [Test] Running logic...")
    Process.sleep(2000)
    assert File.exists?(@config.video_file)
    IO.puts("🧪 [Test] Logic complete.")
  end
end
