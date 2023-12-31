defmodule Servy.ParserTest do
  use ExUnit.Case
  doctest Servy.Parser

  alias Servy.Parser
  alias Servy.Conv

  defp create_request(verb, path) do
    """
    #{verb} #{path} HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """
  end

  describe "parse/1" do
    for verb <- ["GET", "POST", "PUT", "DELETE"] do
      @verb verb
      test "can extract verb #{@verb} from request" do
        assert %Conv{method: @verb} = create_request(@verb, "/bamboozled") |> Parser.parse()
      end
    end

    test "can extract normal path from request" do
      path = "/bamboozled"
      assert %Conv{path: ^path} = create_request("GET", path) |> Parser.parse()
    end

    test "can extract path with subpaths from request" do
      path = "/bamboozled/sub/paths"
      assert %Conv{path: ^path} = create_request("GET", path) |> Parser.parse()
    end

    test "can extract path with number from request" do
      path = "/bamboozled/4"
      assert %Conv{path: ^path} = create_request("GET", path) |> Parser.parse()
    end

    test "can extract path with query parameter from request" do
      path = "/bamboozled?id=4"
      assert %Conv{path: ^path} = create_request("GET", path) |> Parser.parse()
    end

    test "can extract path with query parameters from request" do
      path = "/bamboozled?id=4&bla=adc"
      assert %Conv{path: ^path} = create_request("GET", path) |> Parser.parse()
    end

    test "can extract path with encoded query parameter from request" do
      path = "/bamboozled?id=ab%20cd"
      assert %Conv{path: ^path} = create_request("GET", path) |> Parser.parse()
    end

    test "can extract headers from request" do
      assert %Conv{
               headers: %{
                 "Host" => "example.com",
                 "User-Agent" => "ExampleBrowser/1.0",
                 "Accept" => "*/*"
               }
             } = create_request("GET", "/Baloo") |> Parser.parse()
    end

    test "can extract body params from request" do
      request = """
      POST /bears HTTP/1.1\r
      Host: example.com\r
      User-Agent: ExampleBrowser/1.0\r
      Accept: */*\r
      Content-Type: application/x-www-form-urlencoded\r
      Content-Length: 21\r
      \r
      name=Baloo&type=Brown
      """

      assert %Conv{params: %{"name" => "Baloo", "type" => "Brown"}} = Parser.parse(request)
    end
  end

  describe "parse_headers/1" do
    test "parse list of headers into map" do
      header_lines = ["A: 1", "B: 2"]
      assert %{"A" => "1", "B" => "2"} == Parser.parse_headers(header_lines)
    end
  end
end
