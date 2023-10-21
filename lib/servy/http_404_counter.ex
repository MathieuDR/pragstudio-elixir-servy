defmodule Servy.Http404Counter do
  @pid_name :counter_server
  def start(initial_state \\ %{}) do
    GenericServer.start(__MODULE__, initial_state, @pid_name)
  end

  def get_counts(), do: GenericServer.call(@pid_name, :get_counts)
  def get_count(path), do: get_counts() |> Map.get(path, 0)

  def bump_count(path), do: GenericServer.cast(@pid_name, {:count, path})

  def handle_call(:get_counts, state), do: {state, state}
  def handle_cast({:count, path}, state), do: Map.update(state, path, 1, &Kernel.+(&1, 1))
end
