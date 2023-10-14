defmodule Timer do
  def remind(reminder, time_in_seconds),
    do:
      spawn(fn ->
        :timer.sleep(to_ms(time_in_seconds))
        IO.puts(reminder)
      end)

  defp to_ms(time_in_seconds), do: time_in_seconds * 1000
end
