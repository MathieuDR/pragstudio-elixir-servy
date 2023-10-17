defmodule Servy.Pledges do
  @process_name :pledge_server

  def start() do
    spawn(__MODULE__, :loop, [[]])
    |> Process.register(@process_name)
  end

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
    end
  end

  def create_pledge(name, amount) do
    send(@process_name, {self(), :create_pledge, name, amount})

    receive do
      {:pledge_ok, pledge_id} -> {:ok, pledge_id}
    after
      5000 -> :error
    end
  end

  def get_pledges() do
    send(@process_name, {self(), :get_pledges})

    receive do
      {:pledge_ok, pledges} -> {:ok, pledges |> Enum.take(3)}
    after
      5000 -> :error
    end
  end

  defp send_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
