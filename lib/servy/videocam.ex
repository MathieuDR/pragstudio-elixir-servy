defmodule Servy.Videocam do
  def get_snapshot(camera) do
    :timer.sleep(10000)
    "#{camera}-snapshot.jpg"
  end
end
