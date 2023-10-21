defmodule Servy.Pledges do
  alias GenericServer
  @process_name :pledge_server

  # CLIENT
  def start(initial_state \\ []) do
    GenericServer.start(__MODULE__, initial_state, @process_name)
  end

  def create_pledge(name, amount) do
    {:ok, GenericServer.call(@process_name, {:create_pledge, name, amount})}
  end

  def get_pledges() do
    response =
      GenericServer.call(@process_name, :get_pledges)
      |> Enum.take(3)

    {:ok, response}
  end

  def total_pledged do
    {:ok, GenericServer.call(@process_name, :total_pledged)}
  end

  def clear() do
    GenericServer.cast(@process_name, :pledge_clear)
  end

  # SERVER CALLBACKS

  def handle_cast(:clear, _state), do: []

  def handle_call(:total_pledged, state) do
    {Enum.map(state, &elem(&1, 1)) |> Enum.sum(), state}
  end

  def handle_call(:get_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount} = _message, state) do
    {:ok, pledge_id} = send_to_service(name, amount)
    state = [{name, amount} | state]
    {pledge_id, state}
  end

  defp send_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
