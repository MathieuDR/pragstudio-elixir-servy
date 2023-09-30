defmodule Servy.HandlerTest do
  use ExUnit.Case

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
             Content-Length: 30

             🎉 Teddy, Smokey, Paddington
             """ == Servy.Handler.handle(request)
    end

    test "Can request bear with ID" do
      request = create_request("GET", "/bears/2")

      assert """
             HTTP/1.1 200 OK
             Content-Type: text/html
             Content-Length: 11

             🎉 Bear 2
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

  describe "route/1" do
    test "GET /wildthings routes correctly" do
      conv = create_conv("GET", "/wildthings")
      assert %{resp_body: "Bears, Lions, Tigers", status: 200} = Servy.Handler.route(conv)
    end

    test "GET /bears routes correctly" do
      conv = create_conv("GET", "/bears")
      assert %{resp_body: "Teddy, Smokey, Paddington", status: 200} = Servy.Handler.route(conv)
    end

    test "GET /bears/5 routes correctly" do
      conv = create_conv("GET", "/bears/5")
      assert %{resp_body: "Bear 5", status: 200} = Servy.Handler.route(conv)
    end

    test "DELETE /bears routes correctly" do
      conv = create_conv("DELETE", "/bears/5")
      assert %{resp_body: "Deleted bear 5", status: 200} = Servy.Handler.route(conv)
    end

    for path <- ["/qwerty", "/yala/abc"], verb <- ["GET", "DELETE", "PUT", "POST"] do
      @path path
      @verb verb
      test "#{verb} #{path} returns 404" do
        conv = create_conv(@verb, @path)

        assert %{resp_body: "Resource #{@path} not found", status: 404} =
                 Servy.Handler.route(conv)
      end
    end

    test "GET /bears/new serves form.html" do
      conv = create_conv("GET", "/bears/new")
      assert %{resp_body: "<form" <> _rest, status: 200} = Servy.Handler.route(conv)
    end

    test "GET /pages/about.md serves page" do
      conv = create_conv("GET", "/pages/about.md")
      assert %{resp_body: "# About\n" <> _rest, status: 200} = Servy.Handler.route(conv)
    end

    test "GET /about serves page" do
      conv = create_conv("GET", "/about")
      assert %{resp_body: "# About\n" <> _rest, status: 200} = Servy.Handler.route(conv)
    end

    test "GET /pages/bla.md returns 404" do
      conv = create_conv("GET", "/pages/bla.md")
      assert %{resp_body: "File not found!", status: 404} = Servy.Handler.route(conv)
    end

    test "GET /pages/../bla.md returns 500" do
      conv = create_conv("GET", "/pages/../bla.md")

      assert %{resp_body: "Something went wrong: goes_to_parent", status: 500} =
               Servy.Handler.route(conv)
    end

    test "GET /pages/bla.php returns 500" do
      conv = create_conv("GET", "/pages/bla.php")

      assert %{resp_body: "Something went wrong: wrong_ext", status: 500} =
               Servy.Handler.route(conv)
    end
  end

  describe "rewrite_id_from_query_params/1" do
    defp create_conv(verb, path),
      do: %{method: verb, path: path, resp_body: nil, status: nil}

    test "does not change path with no params" do
      conv = create_conv("GET", "/bears")
      assert ^conv = Servy.Handler.rewrite_id_from_query_params(conv)
    end

    test "does not change path where params does not have id" do
      conv = create_conv("GET", "/bears?blub=9")
      assert ^conv = Servy.Handler.rewrite_id_from_query_params(conv)
    end

    test "changes route when id is present" do
      conv = create_conv("GET", "/bears?id=9")
      assert %{path: "/bears/9"} = Servy.Handler.rewrite_id_from_query_params(conv)
    end

    test "changes route when id is not first param" do
      conv = create_conv("GET", "/bears?blub=8&id=9")
      assert %{path: "/bears/9"} = Servy.Handler.rewrite_id_from_query_params(conv)
    end
  end

  describe "rewrite_path/1" do
    test "Does not change on random string" do
      conv = create_conv("GET", "/bears")
      assert ^conv = Servy.Handler.rewrite_path(conv)
    end

    test "Does change on /wildlife" do
      conv = create_conv("GET", "/wildlife")
      assert %{path: "/wildthings"} = Servy.Handler.rewrite_path(conv)
    end
  end

  describe "emojify/1" do
    for status_code <- [401, 403, 404, 500] do
      @status_code status_code
      test "#{status_code} has no emoji in resp body" do
        %{resp_body: body} =
          %{create_conv("GET", "/no-tada") | status: @status_code, resp_body: "papiot"}
          |> Servy.Handler.emojify()

        assert "papiot" = body
      end
    end

    for status_code <- [200, 201] do
      @status_code status_code
      test "#{status_code} has an emoji in resp body" do
        %{resp_body: body} =
          %{create_conv("GET", "/tada") | status: @status_code, resp_body: "papiot"}
          |> IO.inspect()
          |> Servy.Handler.emojify()

        assert "🎉 papiot" = body
      end
    end
  end
end
