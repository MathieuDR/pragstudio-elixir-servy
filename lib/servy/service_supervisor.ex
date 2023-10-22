defmodule Servy.ServiceSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    [
      {Servy.Pledges, %Servy.Pledges.State{}},
      {Servy.SensorServer, :timer.seconds(60)},
      {Servy.Http404Counter, %{}}
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
