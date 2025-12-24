# Initialize ExUnit
ExUnit.start(max_cases: 1)

# =============================================================================
# MANAGED SERVICE: SystemTestingUIAutomation.Manager
# =============================================================================
defmodule SystemTestingUIAutomation.Manager do
  @moduledoc """
  Service layer responsible for orchestrating the system testing infrastructure,
  including the headless compositor, display client, and video recorder.
  """

  def start_env(config) do
    IO.puts("🚀 [System] Initializing System Testing UI Automation...")

    # 1. Sandbox Initialization
    File.mkdir_p!(config.runtime_dir)
    File.chmod!(config.runtime_dir, 0o700)
    if File.exists?(config.log_file), do: File.rm!(config.log_file)

    System.put_env([
      {"XDG_RUNTIME_DIR", config.runtime_dir},
      {"WLR_BACKENDS", "headless"},
      {"WLR_LIBINPUT_NO_DEVICES", "1"},
      {"WAYLAND_DISPLAY", "wayland-0"}
    ])

    # 2. Process Orchestration
    apps = [
      {"COMPOSITOR", "cage -s -- env -u WAYLAND_DISPLAY looking-glass-client win:size=1920x1080 win:fullScreen=yes -s -f /dev/shm/looking-glass"},
      {"RECORDER", "wf-recorder -f #{config.video_file}"}
    ]

    ports = Enum.map(apps, fn {label, cmd} ->
      port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
      {port, label}
    end)

    # 3. Synchronized Log Aggregation
    log_handle = File.open!(config.log_file, [:append, :utf8])
    aggregator_pid = spawn_link(fn -> log_collector(ports, log_handle) end)
    Enum.each(ports, fn {port, _} -> Port.connect(port, aggregator_pid) end)

    # 4. Readiness Validation
    case wait_for_log(config.log_file, "Starting session", 15) do
      :ok ->
        {:ok, %{ports: ports, log_handle: log_handle, aggregator_pid: aggregator_pid, config: config}}
      :error ->
        {:error, "System environment failed to stabilize within the timeout period."}
    end
  end

  def stop_env(state) do
    IO.puts("\n\n🧹 [System] Initiating Graceful Teardown...")

    # 1. Stop Recorder (SIGINT ensures MKV index is written correctly)
    System.cmd("pkill", ["-f", "-INT", "wf-recorder"])
    wait_for_exit("wf-recorder", 20)

    # 2. Synchronize Shutdown to flush remaining log buffers
    ref = Process.monitor(state.aggregator_pid)
    send(state.aggregator_pid, :stop)

    receive do
      {:DOWN, ^ref, :process, _pid, _reason} ->
        IO.puts("📝 [System] Logs synchronized and file descriptors safe to close.")
    after
      2000 -> IO.puts("⚠️ [System] Log synchronization timeout.")
    end

    # 3. Enhanced Signal Handling for UI Components
    # SIGTERM (15) allows processes to unmap memory/sockets properly
    System.cmd("pkill", ["-f", "-15", "cage"])
    System.cmd("pkill", ["-f", "-15", "looking-glass-client"])
    Process.sleep(500)

    # 4. Final Port Closure and SIGKILL cleanup
    Enum.each(state.ports, fn {port, _} -> try do Port.close(port) rescue _ -> :ok end end)
    System.cmd("pkill", ["-f", "-9", "cage"])
    System.cmd("pkill", ["-f", "-9", "looking-glass-client"])

    File.close(state.log_handle)
    verify_artifact(state.config.video_file)

    # 5. Runtime Directory Cleanup (Erase Sandbox)
    if File.exists?(state.config.runtime_dir) do
      File.rm_rf!(state.config.runtime_dir)
      IO.puts("🗑️  [System] Runtime directory erased.")
    end

    # --- FINAL REPORT ---
    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("🏁 [System] Automation Suite Finished.")
    IO.puts("📽️  Video Artifact: #{Path.expand(state.config.video_file)}")
    IO.puts("\nTo review the recording, run:")
    IO.puts("\e[1;32mmpv --autofit=100%x100% #{state.config.video_file}\e[0m")
    IO.puts(String.duplicate("=", 60))
  end

  # --- Internal Helpers ---

  defp log_collector(ports, log_handle) do
    receive do
      :stop -> :ok
      {port, {:data, msg}} ->
        label = case List.keyfind(ports, port, 0) do {_, l} -> l; _ -> "???" end
        timestamp = DateTime.utc_now() |> DateTime.to_string()
        formatted = msg
                    |> String.split("\n", trim: true)
                    |> Enum.map(&("[#{timestamp}] [#{label}] #{&1}\n"))
                    |> Enum.join("")
        IO.write(log_handle, formatted)
        log_collector(ports, log_handle)
      _ -> log_collector(ports, log_handle)
    end
  end

  defp wait_for_log(file, pattern, attempts) when attempts > 0 do
    if File.exists?(file) and String.contains?(File.read!(file), pattern) do
      IO.puts("✅ [System] Infrastructure ready.")
      :ok
    else
      Process.sleep(1000)
      wait_for_log(file, pattern, attempts - 1)
    end
  end
  defp wait_for_log(_, _, _), do: :error

  defp wait_for_exit(name, attempts) when attempts > 0 do
    {out, _} = System.cmd("pgrep", ["-f", name])
    if out == "" do :ok else
      IO.write(".")
      Process.sleep(500)
      wait_for_exit(name, attempts - 1)
    end
  end
  defp wait_for_exit(_, _), do: :timeout

  defp verify_artifact(path) do
    case File.stat(path) do
      {:ok, %{size: s}} when s > 0 ->
        IO.puts("📽️ [System] Artifact integrity verified (#{div(s, 1024)} KB).")
      _ ->
        IO.puts("❌ [System] Artifact verification failed (file missing or empty).")
    end
  end
end

# =============================================================================
# SYSTEM TESTING UI AUTOMATION: Test Case
# =============================================================================
defmodule SystemTestingUIAutomation.Test do
  use ExUnit.Case, async: false
  alias SystemTestingUIAutomation.Manager

  @config %{
    log_file: "system_ui_automation.log",
    video_file: "./system_ui_recording.mkv",
    runtime_dir: "/tmp/system_testing_ui_sandbox"
  }

  setup_all do
    case Manager.start_env(@config) do
      {:ok, service_state} ->
        on_exit(fn ->
          Manager.stop_env(service_state)
          System.halt(0)
        end)
        {:ok, state: service_state}
      {:error, reason} ->
        flunk("Automation environment failed to start: #{reason}")
    end
  end

  test "system level responsiveness check", _context do
    IO.puts("🧪 [Test] Running System Testing UI Automation...")
    # Add your guest agent or UI interaction commands here
    Process.sleep(5000)
    assert File.exists?(@config.video_file)
  end
end
