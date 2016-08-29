defmodule Owlly.Listener do
  require Logger

  @options [:binary, packet: :line, active: false, reuseaddr: true]

  def start(port) do
    {:ok, socket} = :gen_tcp.listen(port, @options)

    Logger.info "Accepting connections using port #{port}"

    accept_client(socket)
  end

  defp accept_client(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, client_pid} = Owlly.ClientSup.start_client(client)

    accept_client(socket)
  end
end
