defmodule Servy.HandlerTest do
  use ExUnit.Case
  alias Servy.ServySupportTest

  defp create_request(verb, path) do
    """
    #{verb} #{path} HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """
  end

  describe "handle/1" do
    test "returns correct response for request" do
      request = create_request("GET", "/wildthings")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 20\r
             \r
             Bears, Lions, Tigers
             """ == Servy.Handler.handle(request)
    end

    test "Rewrites path for wildlife" do
      request = create_request("GET", "/wildlife")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 20\r
             \r
             Bears, Lions, Tigers
             """ == Servy.Handler.handle(request)
    end

    test "Uses correct route" do
      request = create_request("GET", "/bears")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 346\r
             \r
             <h1>All The Bears!</h1><ul><li>Brutus - Grizzly</li><li>Iceman - Polar</li><li>Kenai - Grizzly</li><li>Paddington - Brown</li><li>Roscoe - Panda</li><li>Rosie - Black</li><li>Scarface - Grizzly</li><li>Smokey - Black</li><li>Snow - Polar</li><li>Teddy - Brown</li></ul>
             """
             |> remove_whitespaces() == Servy.Handler.handle(request) |> remove_whitespaces()
    end

    test "Can request bear with ID" do
      request = create_request("GET", "/bears/2")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 74\r
             \r
             <h1>Show Bear</h1><p>Is Smokey hibernating? <strong>false</strong></p>
             """
             |> remove_whitespaces() == Servy.Handler.handle(request) |> remove_whitespaces()
    end

    test "Can delte bear with ID" do
      request = create_request("DELETE", "/bears/8")

      assert """
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 14\r
             \r
             Deleted bear 8
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

    test "POST /api/bears" do
      request = """
      POST /api/bears HTTP/1.1\r
      Host: example.com\r
      User-Agent: ExampleBrowser/1.0\r
      Accept: */*\r
      Content-Type: application/json\r
      Content-Length: 21\r
      \r
      {"name": "Breezly", "type": "Polar"}
      """

      assert """
             HTTP/1.1 201 Created\r
             Content-Type: text/html\r
             Content-Length: 35\r
             \r
             Created a Polar bear named Breezly!
             """ = Servy.Handler.handle(request)
    end
  end

  describe "create_headers/1" do
    test "Creates headerlines with \\r\\n" do
      headers = %{
        "Content-Type" => "text/html",
        "Content-Length" => 39,
        "X-Custom-Header" => "My value"
      }

      assert 3 = Servy.Handler.create_headers(headers) |> String.split("\r\n") |> Enum.count()
    end

    test "Create headers put Content-Length on top" do
      headers = %{
        "X-Custom-Header" => "My value",
        "Content-Length" => 39
      }

      header_response = Servy.Handler.create_headers(headers)
      assert String.starts_with?(header_response, "Content-Length: ") == true
    end

    test "Create headers put Content-Length and Content-Type on top" do
      headers = %{
        "X-Custom-Header" => "My value",
        "Content-Type" => "text/html",
        "Content-Length" => 39
      }

      assert Servy.Handler.create_headers(headers)
             |> String.split("\r\n")
             |> Enum.take(2)
             |> Enum.all?(&String.starts_with?(&1, "Content-")) == true
    end

    test "Create headers put Content-Type on top" do
      headers = %{
        "X-Custom-Header" => "My value",
        "Content-Type" => "text/html"
      }

      header_response = Servy.Handler.create_headers(headers)
      assert String.starts_with?(header_response, "Content-Type: ") == true
    end
  end

  defp remove_whitespaces(text), do: String.replace(text, ~r{\s}, "")
end
