defmodule Servy.Videocam do
  def get_snapshot(camera) do
    :timer.sleep(Timer.get_random_time(2500))
    "#{camera}-snapshot-#{:rand.uniform(1000)}.jpg"
  end
end
