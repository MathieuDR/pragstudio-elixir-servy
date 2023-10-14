defmodule Servy.HttpServerTest do
  use ExUnit.Case

  @request """
  GET /bears HTTP/1.1\r
  Host: example.com\r
  User-Agent: ExampleBrowser/1.0\r
  Accept: */*\r
  \r
  """

  describe "start/1" do
    test "opens on the correct port" do
      port = 8989
      _server = spawn(fn -> Servy.HttpServer.start(port) end)

      response = Servy.HttpClient.send_and_forget("localhost", port, "abcd")

      # Bad request, gets closed but not resufed.
      assert response == {:error, :closed}
    end
  end
end

