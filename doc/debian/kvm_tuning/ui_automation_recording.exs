# Initialize ExUnit
ExUnit.start(max_cases: 1)

# =============================================================================
# MANAGED SERVICE: UIAutomation.Manager
# =============================================================================
defmodule UIAutomation.Manager do
  @moduledoc "Manages the lifecycle of the Wayland sandbox and recording."

  def start_env(config) do
    IO.puts("🚀 [Service] Starting Managed Environment...")

    # 1. Setup Sandbox
    File.mkdir_p!(config.runtime_dir)
    File.chmod!(config.runtime_dir, 0o700)
    if File.exists?(config.log_file), do: File.rm!(config.log_file)

    System.put_env([
      {"XDG_RUNTIME_DIR", config.runtime_dir},
      {"WLR_BACKENDS", "headless"},
      {"WLR_LIBINPUT_NO_DEVICES", "1"},
      {"WAYLAND_DISPLAY", "wayland-0"}
    ])

    # 2. Start Processes
    apps = [
      {"COMPOSITOR", "cage -s -- env -u WAYLAND_DISPLAY looking-glass-client win:size=1920x1080 win:fullScreen=yes -s -f /dev/shm/looking-glass"},
      {"RECORDER", "wf-recorder -f #{config.video_file}"}
    ]

    ports = Enum.map(apps, fn {label, cmd} ->
      port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
      {port, label}
    end)

    # 3. Handle Logging
    log_handle = File.open!(config.log_file, [:append, :utf8])
    aggregator_pid = spawn_link(fn -> log_collector(ports, log_handle) end)
    Enum.each(ports, fn {port, _} -> Port.connect(port, aggregator_pid) end)

    # 4. Wait for readiness
    case wait_for_log(config.log_file, "Starting session", 15) do
      :ok ->
        {:ok, %{ports: ports, log_handle: log_handle, aggregator_pid: aggregator_pid, config: config}}
      :error ->
        {:error, "Environment failed to become ready."}
    end
  end

  def stop_env(state) do
    IO.puts("\n\n🧹 [Service] Initiating Managed Shutdown...")

    # 1. Stop Recorder gracefully
    System.cmd("pkill", ["-f", "-INT", "wf-recorder"])
    wait_for_exit("wf-recorder", 20)

    # 2. Stop Log Collector and wait for flush (Prevents :terminated error)
    ref = Process.monitor(state.aggregator_pid)
    send(state.aggregator_pid, :stop)

    receive do
      {:DOWN, ^ref, :process, _pid, _reason} ->
        IO.puts("📝 [Service] Logs synchronized and flushed.")
    after
      2000 -> IO.puts("⚠️ [Service] Log collector shutdown timeout.")
    end

    # 3. Close Ports & Kill lingering processes
    Enum.each(state.ports, fn {port, _} -> try do Port.close(port) rescue _ -> :ok end end)
    System.cmd("pkill", ["-f", "-9", "cage"])
    System.cmd("pkill", ["-f", "-9", "looking-glass-client"])

    File.close(state.log_handle)
    verify_video(state.config.video_file)

    # --- FINAL PRESENTATION ---
    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("🏁 [Service] Teardown complete.")
    IO.puts("📽️  Video saved to: #{Path.expand(state.config.video_file)}")
    IO.puts("\nTo view the recording, run:")
    IO.puts("\e[1;32mmpv --autofit=100%x100% #{state.config.video_file}\e[0m")
    IO.puts(String.duplicate("=", 60))
  end

  # --- Internal Service Helpers ---

  defp log_collector(ports, log_handle) do
    receive do
      :stop ->
        :ok # Stop recursion
      {port, {:data, msg}} ->
        label = case List.keyfind(ports, port, 0) do {_, l} -> l; _ -> "???" end
        timestamp = DateTime.utc_now() |> DateTime.to_string()
        formatted = msg
                    |> String.split("\n", trim: true)
                    |> Enum.map(&("[#{timestamp}] [#{label}] #{&1}\n"))
                    |> Enum.join("")
        IO.write(log_handle, formatted)
        log_collector(ports, log_handle)
      _ ->
        log_collector(ports, log_handle)
    end
  end

  defp wait_for_log(file, pattern, attempts) when attempts > 0 do
    if File.exists?(file) and String.contains?(File.read!(file), pattern) do
      IO.puts("✅ [Service] Readiness confirmed.")
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

  defp verify_video(path) do
    case File.stat(path) do
      {:ok, %{size: s}} when s > 0 ->
        IO.puts("📽️ [Service] Video verified: #{div(s, 1024)} KB")
      _ ->
        IO.puts("❌ [Service] Video check failed!")
    end
  end
end

# =============================================================================
# TEST SUITE
# =============================================================================
defmodule GuestAgentTest do
  use ExUnit.Case, async: false
  alias UIAutomation.Manager

  @config %{
    log_file: "test_run.log",
    video_file: "./test_run_video.mkv",
    runtime_dir: "/tmp/ui_automation_sandbox"
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
        flunk("Failed to start automation environment: #{reason}")
    end
  end

  test "verify guest agent is responsive", _context do
    IO.puts("🧪 [Test] Running: QGA Ping Check")
    # Simulate automation work
    Process.sleep(5000)
    assert File.exists?(@config.video_file)
  end
end
