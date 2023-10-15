defmodule Servy.Videocam do
  def get_snapshot(camera) do
    :timer.sleep(1000)
    "#{camera}-snapshot.jpg"
  end
end
