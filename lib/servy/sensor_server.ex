defmodule Servy.SensorServer do
  @name :sensor_server
  use GenServer

  defmodule State do
    defstruct interval: 5000, data: %{}
  end

  def start_link(seconds \\ 5000) do
    IO.puts("start sensors")
    GenServer.start_link(__MODULE__, %State{interval: seconds}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def change_interval(time_in_seconds) do
    GenServer.cast(@name, {:change_interval, time_in_seconds})
  end

  def init(%State{} = state) do
    data = get_sensor_info()
    schedule_refresh(state.interval)
    {:ok, %{state | data: data}}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.data, state}
  end

  def handle_info(:refresh, %State{} = state) do
    schedule_refresh(state.interval)
    state = %{state | data: get_sensor_info()}
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def handle_cast({:change_interval, interval}, %State{} = state),
    do: {:noreply, %State{state | interval: interval}}

  defp schedule_refresh(seconds) do
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
