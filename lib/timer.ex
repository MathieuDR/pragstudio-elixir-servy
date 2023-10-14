defmodule Timer do
  def remind(reminder, time_in_seconds),
    do:
      spawn(fn ->
        :timer.sleep(to_ms(time_in_seconds))
        IO.puts(reminder)
      end)

  def power_nap do
    time = :rand.uniform(10000)
    :timer.sleep(time)
    time
  end

  def spawn_nap do
    p = self()

    spawn(fn -> send(p, {:ok, power_nap()}) end)

    receive do
      {:ok, time} -> "slept #{time}ms"
    end
  end

  defp to_ms(time_in_seconds), do: time_in_seconds * 1000
end
