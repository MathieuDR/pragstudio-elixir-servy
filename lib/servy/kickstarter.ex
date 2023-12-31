defmodule Servy.Kickstarter do
  use GenServer
  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    {:ok, start_server()}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HttpServer broken: #{reason}")
    {:noreply, start_server()}
  end

  defp start_server() do
    pid = spawn_link(Servy.HttpServer, :start, [Application.get_env(:servy, :port)])
    Process.register(pid, :http_server)
    pid
  end
end
