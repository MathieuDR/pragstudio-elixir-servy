defmodule Servy.Models.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def is_type?(bear, type), do: bear.type == type
end

