defmodule Servy.ServySupportTest do
  def create_conv(verb, path),
    do: %Servy.Conv{method: verb, path: path, resp_body: nil, status_code: nil}
end
