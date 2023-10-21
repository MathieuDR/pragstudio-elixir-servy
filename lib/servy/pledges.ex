defmodule Servy.Pledges do
  @process_name :pledge_server

  # CLIENT
  def start(initial_state \\ []) do
    spawn(__MODULE__, :loop, [initial_state])
    |> Process.register(@process_name)
  end

  def create_pledge(name, amount) do
    {:ok, call(@process_name, {:create_pledge, name, amount})}
  end

  def get_pledges() do
    response =
      call(@process_name, :get_pledges)
      |> Enum.take(3)

    {:ok, response}
  end

  def total_pledged do
    {:ok, call(@process_name, :total_pledged)}
  end

  def clear() do
    cast(@process_name, :pledge_clear)
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    after
      5000 -> :error
    end
  end

  # SERVER
  def loop(state) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, state} = handle_call(message, state)
        send(sender, {:response, response})
        loop(state)

      {:cast, message} ->
        state = handle_cast(message, state)
        loop(state)

      other ->
        IO.puts("UNKNOWN MESAGE: #{inspect(other)}")
    end
  end

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
