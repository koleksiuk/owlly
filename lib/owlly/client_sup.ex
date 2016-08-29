defmodule Owlly.ClientSup do
  use Supervisor

  @name Owlly.ClientSup

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_client(socket) do
    Supervisor.start_child(@name, [socket])
  end

  def init(:ok) do
    children = [
      worker(Owlly.Client, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
