defmodule Fetcher do
  def async(function) do
    p = self()
    spawn(fn -> send(p, {:ok, self(), function.()}) end)
  end

  def get_result(pid) do
    receive do
      {:ok, ^pid, result} -> result
    end
  end
end
