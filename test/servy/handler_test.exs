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
             HTTP/1.1 200 OK
             Content-Type: text/html
             Content-Length: 25

             🎉 Bears, Lions, Tigers
             """ == Servy.Handler.handle(request)
    end

    test "Rewrites path for wildlife" do
      request = create_request("GET", "/wildlife")

      assert """
             HTTP/1.1 200 OK
             Content-Type: text/html
             Content-Length: 25

             🎉 Bears, Lions, Tigers
             """ == Servy.Handler.handle(request)
    end

    test "Uses correct route" do
      request = create_request("GET", "/bears")

      assert """
             HTTP/1.1 200 OK
             Content-Type: text/html
             Content-Length: 90

             🎉 <ul><li>Brutus - Grizzly</li><li>Kenai - Grizzly</li><li>Scarface - Grizzly</li></ul>
             """ == Servy.Handler.handle(request)
    end

    test "Can request bear with ID" do
      request = create_request("GET", "/bears/2")

      assert """
             HTTP/1.1 200 OK
             Content-Type: text/html
             Content-Length: 19

             🎉 Smokey - Black
             """ == Servy.Handler.handle(request)
    end

    test "Can delte bear with ID" do
      request = create_request("DELETE", "/bears/8")

      assert """
             HTTP/1.1 200 OK
             Content-Type: text/html
             Content-Length: 19

             🎉 Deleted bear 8
             """ == Servy.Handler.handle(request)
    end

    test "Returns 404 not found for not found path" do
      request = create_request("GET", "/bamboozled")

      assert """
             HTTP/1.1 404 Not Found
             Content-Type: text/html
             Content-Length: 30

             Resource /bamboozled not found
             """ == Servy.Handler.handle(request)
    end
  end
end
