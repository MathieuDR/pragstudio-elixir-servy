defmodule Servy.HttpServerTest do
  use ExUnit.Case

  describe "start/1" do
    test "opens on the correct port" do
      port = 8990
      _server = spawn(fn -> Servy.HttpServer.start(port) end)

      response = Servy.HttpClient.send_and_forget("localhost", port, "abcd")

      # Bad request, gets closed but not refused.
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
        spawn(fn ->
          assert {:ok, response} = HTTPoison.get("localhost:#{port}/wildthings")
          send(pid, {:ok, response.body})
        end)
      end)
      |> Enum.map(fn _ ->
        response =
          receive do
            {:ok, response} -> response
          end

        assert "Bears, Lions, Tigers" == response
      end)
    end

    test "Use tasks" do
      port = 8799
      _server = spawn(fn -> Servy.HttpServer.start(port) end)

      Enum.map(1..5, fn _i ->
        Task.async(fn -> HTTPoison.get("localhost:#{port}/wildthings") end)
      end)
      |> Enum.map(fn task ->
        assert {:ok, %HTTPoison.Response{status_code: 200, body: "Bears, Lions, Tigers"}} =
                 Task.await(task)
      end)
    end

    test "Sanity check urls" do
      port = 9000
      _server = spawn(fn -> Servy.HttpServer.start(port) end)

      ["/wildthings", "/sensors", "/bears/new", "/about"]
      |> Enum.map(&Task.async(fn -> HTTPoison.get("localhost:#{port}#{&1}") end))
      |> Enum.map(&Task.await(&1))
      |> Enum.each(fn {:ok, %{status_code: code}} -> assert code == 200 end)
    end
  end
end
