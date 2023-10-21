defmodule Servy.Pledges do
  @process_name :pledge_server

  # CLIENT
  def start(initial_state \\ []) do
    spawn(__MODULE__, :loop, [initial_state])
    |> Process.register(@process_name)
  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})

    {:ok, receive_message()}
  end

  def get_pledges() do
    send(@process_name, {self(), :get_pledges})
    {:ok, receive_message() |> Enum.take(3)}
  end

  def total_pledged do
    send(@process_name, {self(), :total_pledged})
    {:ok, receive_message()}
  end

  # SERVER
  def loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, pledge_id} = send_to_service(name, amount)
        state = [{name, amount} | state]
        send(sender, {:pledge_ok, pledge_id})
        loop(state)

      {sender, :get_pledges} ->
        send(sender, {:pledge_ok, state})
        loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:pledge_ok, total})
        loop(state)

      other ->
        IO.puts("UNKNOWN MESAGE: #{inspect(other)}")
    end
  end

  defp receive_message() do
    receive do
      {:pledge_ok, result} -> result
    after
      5000 -> :error
    end
  end

  defp send_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
