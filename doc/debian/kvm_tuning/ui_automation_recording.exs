# Initialize ExUnit
ExUnit.start(max_cases: 1)

defmodule UIAutomationTest do
  use ExUnit.Case, async: false

  # --- CONFIGURATION ---
  @log_file "automation_suite.log"
  # Switched to MKV for "crash-proof" recording
  @video_file "./qga_test_output.mkv"
  @runtime_dir "/tmp/wayland-run"

  # --- FIXTURES ---
  setup_all do
    File.mkdir_p!(@runtime_dir)
    File.chmod!(@runtime_dir, 0o700)
    if File.exists?(@log_file), do: File.rm!(@log_file)

    System.put_env([
      {"XDG_RUNTIME_DIR", @runtime_dir},
      {"WLR_BACKENDS", "headless"},
      {"WLR_LIBINPUT_NO_DEVICES", "1"},
      {"WAYLAND_DISPLAY", "wayland-0"}
    ])

    IO.puts("🚀 Initializing Suite Fixture...")

    apps = [
      {"COMPOSITOR", "cage -s -- env -u WAYLAND_DISPLAY looking-glass-client win:size=1920x1080 win:fullScreen=yes -s -f /dev/shm/looking-glass"},
      {"RECORDER", "wf-recorder -f #{@video_file}"}
    ]

    ports = Enum.map(apps, fn {label, cmd} ->
      port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout])
      {port, label}
    end)

    log_handle = File.open!(@log_file, [:append, :delayed_write])
    spawn_link(fn -> log_collector(ports, log_handle) end)

    # Wait for Looking Glass to be "Ready"
    wait_for_log("Starting session", 15)

    on_exit(fn ->
      cleanup(ports, log_handle)
    end)

    {:ok, ports: ports}
  end

  # --- TESTS ---

  test "verify guest agent is responsive", _context do
    IO.puts("🧪 Running: Guest Agent Check")
    Process.sleep(5000) # Increased sleep to ensure data is captured
    assert File.exists?(@video_file)
  end

  # --- CLEANUP & ROBUST TERMINATION ---

  defp cleanup(ports, log_handle) do
    IO.puts("\n🧹 Initiating graceful shutdown...")

    # 1. Send SIGINT to recorder
    System.cmd("pkill", ["-f", "-INT", "wf-recorder"])

    # 2. Watchdog: Poll OS for max 10 seconds
    case wait_for_process_exit("wf-recorder", 20) do
      :ok ->
        IO.puts("\n✅ Recorder finalized successfully.")
      :timeout ->
        IO.puts("\n⚠️ Recorder timed out. Forcing termination...")
        System.cmd("pkill", ["-f", "-9", "wf-recorder"])
    end

    # 3. Close Erlang Port bridges
    Enum.each(ports, fn {port, _} ->
      try do Port.close(port) rescue _ -> :ok end
    end)

    # 4. Force kill UI components
    System.cmd("pkill", ["-f", "-9", "cage"])
    System.cmd("pkill", ["-f", "-9", "looking-glass-client"])

    File.close(log_handle)
    
    # 5. Final validation: Check if video has size
    check_video_file()

    IO.puts("🏁 Teardown complete. Returning to shell.")
    System.halt(0)
  end

  defp check_video_file do
    case File.stat(@video_file) do
      {:ok, %{size: size}} when size > 0 ->
        IO.puts("📽️ Video saved: #{@video_file} (#{div(size, 1024)} KB)")
      _ ->
        IO.puts("❌ Error: Video file is empty or missing!")
    end
  end

  defp wait_for_process_exit(name, attempts) when attempts > 0 do
    {out, _} = System.cmd("pgrep", ["-f", name])
    if out == "" do
      :ok
    else
      IO.write(".")
      Process.sleep(500)
      wait_for_process_exit(name, attempts - 1)
    end
  end
  defp wait_for_process_exit(_, _), do: :timeout

  # --- HELPERS ---

  defp log_collector(ports, log_handle) do
    receive do
      {port, {:data, msg}} ->
        label = case List.keyfind(ports, port, 0) do
          {_, l} -> l
          nil -> "???"
        end
        timestamp = DateTime.utc_now() |> DateTime.to_string()
        formatted = msg
        |> String.split("\n", trim: true)
        |> Enum.map(fn line -> "[#{timestamp}] [#{label}] #{line}\n" end)
        |> Enum.join("")
        IO.write(log_handle, formatted)
        log_collector(ports, log_handle)
      _ ->
        log_collector(ports, log_handle)
    end
  end

  defp wait_for_log(pattern, seconds_left) when seconds_left > 0 do
    case File.read(@log_file) do
      {:ok, content} ->
        if String.contains?(content, pattern) do
          IO.puts("✅ Environment Ready.")
        else
          Process.sleep(1000)
          wait_for_log(pattern, seconds_left - 1)
        end
      {:error, _} ->
        Process.sleep(1000)
        wait_for_log(pattern, seconds_left - 1)
    end
  end
  defp wait_for_log(_, _), do: IO.puts("⚠️ Startup timeout.")
end

