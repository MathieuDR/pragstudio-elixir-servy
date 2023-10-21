defmodule SpawnSupport do
  def reset_or_start_server(name, start_fun, start_params) do
    Process.whereis(name)
    |> case do
      nil ->
        :ok

      pid ->
        Process.unregister(name)
        Process.exit(pid, :kill)
    end

    start_fun.(start_params)
  end
end
