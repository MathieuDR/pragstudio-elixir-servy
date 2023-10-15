defmodule Servy.HttpServerTest do
  use ExUnit.Case

  describe "start/1" do
    test "opens on the correct port" do
      port = 8990
      _server = spawn(fn -> Servy.HttpServer.start(port) end)

      response = Servy.HttpClient.send_and_forget("localhost", port, "abcd")

      # Bad request, gets closed but not resufed.
      assert response == {:error, :closed}
    end

    test "use httpoison" do
      port = 8988
      _server = spawn(fn -> Servy.HttpServer.start(port) end)

      assert {:ok, response} = HTTPoison.get("localhost:#{port}/wildthings")
      assert "Bears, Lions, Tigers" == response.body
    end

    test "use httpoison in processes" do
      port = 8999
      pid = self()
      _server = spawn(fn -> Servy.HttpServer.start(port) end)

      Enum.map(1..5, fn _i ->
        assert {:ok, response} = HTTPoison.get("localhost:#{port}/wildthings")
        send(pid, {:ok, response.body})
      end)
      |> Enum.map(fn _ ->
        response =
          receive do
            {:ok, response} -> response
          end

        assert "Bears, Lions, Tigers" == response
      end)
    end
  end
end
