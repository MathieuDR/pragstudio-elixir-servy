defmodule Servy do
  use Application

  def start(_type, _args) do
    IO.puts("starting #{__MODULE__}")
    Servy.Supervisor.start_link()
  end
end
