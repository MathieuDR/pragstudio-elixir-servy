defmodule Servy.SensorServer do
  @name :sensor_server
  @delay :timer.seconds(5)
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: @name)
  end

  def get_sensor_data do
  end

  def init(_state) do
    state = get_sensor_info()
    schedule_refresh()
    {:ok, state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, _state) do
    schedule_refresh()
    {:noreply, get_sensor_info()}
  end

  defp schedule_refresh(seconds \\ @delay) do
    Process.send_after(self(), :refresh, seconds)
  end

  defp get_sensor_info() do
    snapshot_tasks =
      Enum.map(1..3, &Task.async(fn -> Servy.Videocam.get_snapshot("camera-#{&1}") end))

    location_task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)
    snapshots = Enum.map(snapshot_tasks, &Task.await/1)
    location = Task.await(location_task)

    %{snapshots: snapshots, location: location}
  end
end
