defmodule Servy.Http404Counter do
  @pid_name :counter_server
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: @pid_name)
  end

  def get_counts(), do: GenServer.call(@pid_name, :get_counts)
  def get_count(path), do: get_counts() |> Map.get(path, 0)
  def reset(), do: GenServer.cast(@pid_name, :reset)

  def bump_count(path), do: GenServer.cast(@pid_name, {:count, path})

  def handle_call(:get_counts, _from, state), do: {:reply, state, state}

  def handle_cast({:count, path}, state),
    do: {:noreply, Map.update(state, path, 1, &Kernel.+(&1, 1))}

  def handle_cast(:reset, _state), do: {:noreply, %{}}
end
