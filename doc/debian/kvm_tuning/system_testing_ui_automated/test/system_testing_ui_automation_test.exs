defmodule SystemTestingUIAutomation.Config do
  @enforce_keys [:log_file, :video_file, :runtime_dir, :vm_name]
  defstruct [:log_file, :video_file, :runtime_dir, :vm_name]
end

defmodule SystemTestingUIAutomation.Manager do
  alias SystemTestingUIAutomation.Config

  def start_env(%Config{} = config) do
    IO.puts("🚀 [System] Initializing System Testing UI Automation...")
    Process.flag(:trap_exit, true)

    File.mkdir_p!(config.runtime_dir)
    File.chmod!(config.runtime_dir, 0o700)

    final_video = String.replace(config.video_file, Path.extname(config.video_file), "_final.mp4")
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
      {:os_pid, os_pid} = Port.info(port, :os_pid)

      Port.connect(port, aggregator_pid)
      send(aggregator_pid, {:register, port, label, self()})
      receive do: ({:registered, ^port} -> :ok)

      %{port: port, label: label, os_pid: os_pid}
    end)

    case wait_for_log(config.log_file, "Starting session", 15) do
      :ok -> {:ok, %{ports: ports, log_handle: log_handle, aggregator_pid: aggregator_pid, config: config}}
      :error ->
        Enum.each(ports, fn %{os_pid: pid} -> System.cmd("kill", ["-9", to_string(pid)]) end)
        {:error, "Infrastructure failed to stabilize."}
    end
  end

  def stop_env(state) do
    IO.puts("\n\n🧹 [System] Initiating Teardown...")

    Enum.each(state.ports, fn %{os_pid: pid, label: label} ->
      signal = if label == "RECORDER", do: "-2", else: "-15"
      IO.puts("Stopping #{label} (PID #{pid}) with signal #{signal}...")
      System.cmd("kill", [signal, to_string(pid)])
    end)

    Process.sleep(3000)

    Enum.each(state.ports, fn %{port: port} ->
      if Port.info(port), do: Port.close(port)
    end)

    run_managed_compression(state, "COMPRESSION")

    if Process.alive?(state.aggregator_pid) do
      ref = Process.monitor(state.aggregator_pid)
      send(state.aggregator_pid, :stop)
      receive do: ({:DOWN, ^ref, :process, _pid, _reason} -> :ok), after: (5000 -> :ok)
    end

    File.close(state.log_handle)
    if File.exists?(state.config.runtime_dir), do: File.rm_rf!(state.config.runtime_dir)
    print_report(state.config)
  end

  def qemu_agent_exec(vm_name, path, args) do
    payload = Jason.encode!(%{
      execute: "guest-exec",
      arguments: %{path: path, arg: args, "capture-output": true}
    })

    case System.cmd("virsh", ["-c", "qemu:///system", "qemu-agent-command", vm_name, payload]) do
      {output, 0} ->
        case Jason.decode(output) do
          {:ok, %{"return" => %{"pid" => pid}}} -> {:ok, pid}
          _ -> {:error, "Unexpected response: #{output}"}
        end
      {err, _} -> {:error, err}
    end
  end

  def wait_for_guest_exec(vm_name, pid, attempts \\ 20) do
    payload = Jason.encode!(%{execute: "guest-exec-status", arguments: %{pid: pid}})

    case System.cmd("virsh", ["-c", "qemu:///system", "qemu-agent-command", vm_name, payload]) do
      {output, 0} ->
        case Jason.decode!(output) do
          %{"return" => %{"exited" => true} = result} -> {:ok, result}
          _ when attempts > 0 ->
            Process.sleep(1000)
            wait_for_guest_exec(vm_name, pid, attempts - 1)
          _ -> {:error, "Timeout waiting for PID #{pid}"}
        end
      {err, _} -> {:error, err}
    end
  end

  defp run_managed_compression(state, label) do
    in_path = state.config.video_file
    if File.exists?(in_path) and File.stat!(in_path).size > 0 do
      out_path = String.replace(in_path, Path.extname(in_path), "_final.mp4")
      IO.puts("🗜️  [System] Compressing video...")

      args = ["-nostats", "-loglevel", "info", "-i", in_path, "-vcodec", "libx264", "-preset", "medium", "-crf", "23", "-threads", "0", "-y", out_path]
      cmd = "ffmpeg " <> Enum.join(args, " ")

      port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
      send(state.aggregator_pid, {:register, port, label, self()})
      receive do: ({:registered, ^port} -> :ok)
      Port.connect(port, state.aggregator_pid)

      receive do
        {:port_exit, ^label, 0} ->
          if File.exists?(out_path), do: File.rm!(in_path)
        _ -> :error
      after 300_000 -> :timeout
      end
    else
      IO.puts("⚠️  [System] Skip compression: Video file missing or empty.")
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
      :stop -> drain_mailbox(port_map, log_handle)
    end
  end

  defp drain_mailbox(port_map, handle) do
    receive do
      {port, {:data, msg}} ->
        {label, _} = Map.get(port_map, port, {"DRAIN", nil})
        write_to_file(label, msg, handle)
        drain_mailbox(port_map, handle)
    after 1000 -> :ok
    end
  end

  defp write_to_file(label, msg, handle) do
    ts = DateTime.utc_now() |> DateTime.to_string()
    formatted = msg |> String.split("\n", trim: true) |> Enum.map_join(&("[#{ts}] [#{label}] #{&1}\n"))
    try do
      IO.write(handle, formatted)
      :file.datasync(handle)
    rescue
      _ -> :ok
    end
  end

  defp wait_for_log(file, pattern, attempts) when attempts > 0 do
    if File.exists?(file) and String.contains?(File.read!(file), pattern) do
      :ok
    else
      Process.sleep(1000)
      wait_for_log(file, pattern, attempts - 1)
    end
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

defmodule SystemTestingUIAutomation.Test do
  use ExUnit.Case, async: false
  alias SystemTestingUIAutomation.Manager
  alias SystemTestingUIAutomation.Config

  @config %Config{
    log_file: "system_testing.log",
    video_file: "./system_testing.mkv",
    runtime_dir: "/tmp/system_testing_runtime",
    vm_name: "win11"
  }

  setup_all do
    case Manager.start_env(@config) do
      {:ok, state} ->
        on_exit(fn -> Manager.stop_env(state) end)
        {:ok, state: state}
      {:error, reason} -> flunk(reason)
    end
  end

  test "notepad lifecycle via qemu-agent and task scheduler", _context do
    vm = @config.vm_name
    tn = "SystemTestingUIAutomation"

    IO.puts("🔨 [Step 1] Registering Scheduled Task...")
    ps = "$action = New-ScheduledTaskAction -Execute 'notepad.exe'; " <>
         "$principal = New-ScheduledTaskPrincipal -UserId 'thierry' -LogonType Interactive -RunLevel Highest; " <>
         "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries; " <>
         "Register-ScheduledTask -TaskName '#{tn}' -Action $action -Principal $principal -Settings $settings -Force"

    {:ok, pid1} = Manager.qemu_agent_exec(vm, "powershell.exe", ["-Command", ps])
    {:ok, res1} = Manager.wait_for_guest_exec(vm, pid1)
    assert res1["exitcode"] == 0

    IO.puts("🚀 [Step 2] Executing Task (Opening Notepad)...")
    {:ok, pid3} = Manager.qemu_agent_exec(vm, "schtasks.exe", ["/Run", "/TN", tn])
    {:ok, res3} = Manager.wait_for_guest_exec(vm, pid3)
    assert res3["exitcode"] == 0

    Process.sleep(5000)

    IO.puts("🧹 [Step 3] Deleting Task...")
    {:ok, pid4} = Manager.qemu_agent_exec(vm, "schtasks.exe", ["/Delete", "/TN", tn, "/F"])
    {:ok, res4} = Manager.wait_for_guest_exec(vm, pid4)
    assert res4["exitcode"] == 0

    IO.puts("✅ [Test] Sequence verified.")
  end
end
