defmodule Servy.Pledges do
  @process_name :pledge_server
  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # CLIENT
  def start(%State{} = initial_state \\ %State{}) do
    GenServer.start(__MODULE__, initial_state, name: @process_name)
  end

  def create_pledge(name, amount) do
    {:ok, GenServer.call(@process_name, {:create_pledge, name, amount})}
  end

  def get_pledges() do
    response = GenServer.call(@process_name, :get_pledges)

    {:ok, response}
  end

  def set_cache_size(size) do
    GenServer.cast(@process_name, {:set_cache_size, size})
    :ok
  end

  def total_pledged do
    {:ok, GenServer.call(@process_name, :total_pledged)}
  end

  def clear() do
    GenServer.cast(@process_name, :pledge_clear)
  end

  # SERVER CALLBACKS
  def init(state) do
    {:ok, %State{state | pledges: fetch_pledges_from_db() ++ state.pledges}}
  end

  def handle_cast(:clear, state), do: {:noreply, %State{state | pledges: []}}

  def handle_cast({:set_cache_size, size}, state),
    do: {:noreply, %State{state | cache_size: size}}

  def handle_call(:total_pledged, _from, state) do
    {:reply, Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum(), state}
  end

  def handle_call(:get_pledges, _from, state) do
    {:reply, state.pledges |> Enum.take(state.cache_size), state}
  end

  def handle_call({:create_pledge, name, amount} = _message, _from, state) do
    {:ok, pledge_id} = send_to_service(name, amount)
    state = %State{state | pledges: [{name, amount} | state.pledges]}
    {:reply, pledge_id, state}
  end

  defp send_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  def handle_info(_message, state) do
    IO.puts("nani")
    {:noreply, state}
  end

  defp fetch_pledges_from_db() do
    [{"Blieken", 25}]
  end
end
