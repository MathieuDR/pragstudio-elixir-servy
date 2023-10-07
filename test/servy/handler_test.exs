defmodule Servy.HandlerTest do
  use ExUnit.Case
  alias Servy.ServySupportTest

  defp create_request(verb, path) do
    """
    #{verb} #{path} HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """
  end

  describe "handle/1" do
    test "returns correct response for request" do
      request = create_request("GET", "/wildthings")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 25\r
             \r
             🎉 Bears, Lions, Tigers
             """ == Servy.Handler.handle(request)
    end

    test "Rewrites path for wildlife" do
      request = create_request("GET", "/wildlife")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 25\r
             \r
             🎉 Bears, Lions, Tigers
             """ == Servy.Handler.handle(request)
    end

    test "Uses correct route" do
      request = create_request("GET", "/bears")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 351\r
             \r
             🎉 <h1>All The Bears!</h1><ul><li>Brutus - Grizzly</li><li>Iceman - Polar</li><li>Kenai - Grizzly</li><li>Paddington - Brown</li><li>Roscoe - Panda</li><li>Rosie - Black</li><li>Scarface - Grizzly</li><li>Smokey - Black</li><li>Snow - Polar</li><li>Teddy - Brown</li></ul>
             """
             |> remove_whitespaces() == Servy.Handler.handle(request) |> remove_whitespaces()
    end

    test "Can request bear with ID" do
      request = create_request("GET", "/bears/2")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 79\r
             \r
             🎉 <h1>Show Bear</h1><p>Is Smokey hibernating? <strong>false</strong></p>
             """
             |> remove_whitespaces() == Servy.Handler.handle(request) |> remove_whitespaces()
    end

    test "Can delte bear with ID" do
      request = create_request("DELETE", "/bears/8")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 19\r
             \r
             🎉 Deleted bear 8
             """ == Servy.Handler.handle(request)
    end

    test "Returns 404 not found for not found path" do
      request = create_request("GET", "/bamboozled")

      assert """
             HTTP/1.1 404 Not Found\r
             Content-Type: text/html\r
             Content-Length: 30\r
             \r
             Resource /bamboozled not found
             """ == Servy.Handler.handle(request)
    end
  end

  defp remove_whitespaces(text), do: String.replace(text, ~r{\s}, "")
end
