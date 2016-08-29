defmodule Owlly.Client do
  require Logger

  ## Client API

  def start_link(client) do
    GenServer.start_link(__MODULE__, client, [])
  end

  defp command(pid, msg) do
    GenServer.call(pid, {:command, msg})
  end

  def socked_closed(pid) do
    GenServer.cast(pid, :closed)
  end

  ## ServerAPI

  def init(client) do
    send(self, {:real_init, client})

    {:ok, nil}
  end

  def handle_call({:command, msg}, _from, client) do
    Logger.info "Received command: #{msg}"

    {:reply, msg, client}
  end

  def handle_cast(:closed, client) do
    {:stop, :normal, client}
  end

  def handle_info({:real_init, client}, nil) do
    Logger.debug "Accepting connections for client #{inspect(client)}"

    pid = self()

    spawn_link(fn -> read_message(pid, client) end)

    {:noreply, client}
  end

  def terminate(reason, _status) do
    Logger.info "Terminating GenServer. Reason: #{inspect reason}"
    :ok
  end

  defp read_message(pid, client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, message} ->
        message |> send_message(client) |> Logger.info
        command(pid, message)
        read_message(pid, client)
      {:error, _} ->
        :gen_tcp.close(client)
        Logger.debug "Closed connection, terminating"
        socked_closed(pid)
    end
  end

  defp send_message(message, client) do
    :gen_tcp.send(client, message)

    message
  end
end
