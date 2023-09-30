defmodule Servy.ServySupportTest do
  def create_conv(verb, path),
    do: %{method: verb, path: path, resp_body: nil, status: nil}
end
