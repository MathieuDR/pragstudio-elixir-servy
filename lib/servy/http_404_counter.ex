defmodule Servy.Http404Counter do
  @pid_name __MODULE__
  def start(initial_state \\ %{}) do
    Process.whereis(@pid_name)
    |> case do
      nil -> start_server(initial_state)
      _ -> :ok
    end
  end

  def get_counts(), do: Agent.get(@pid_name, fn state -> state end)
  def get_count(path), do: get_counts() |> Map.get(path, 0)

  def bump_count(path) do
    Agent.update(@pid_name, fn state ->
      Map.update(state, path, 1, &Kernel.+(&1, 1))
    end)
  end

  defp start_server(initial_state) do
    Agent.start(fn -> initial_state end)
    |> elem(1)
    |> Process.register(@pid_name)
  end
end
