defmodule Servy.RouterTest do
  use ExUnit.Case
  alias Servy.ServySupportTest
  alias Servy.Router

  describe "route/1" do
    test "GET /wildthings routes correctly" do
      conv = ServySupportTest.create_conv("GET", "/wildthings")
      assert %{resp_body: "Bears, Lions, Tigers", status_code: 200} = Router.route(conv)
    end

    test "GET /bears routes correctly" do
      conv = ServySupportTest.create_conv("GET", "/bears")
      assert %{resp_body: "Teddy, Smokey, Paddington", status_code: 200} = Router.route(conv)
    end

    test "GET /bears/5 routes correctly" do
      conv = ServySupportTest.create_conv("GET", "/bears/5")
      assert %{resp_body: "Bear 5", status_code: 200} = Router.route(conv)
    end

    test "DELETE /bears routes correctly" do
      conv = ServySupportTest.create_conv("DELETE", "/bears/5")
      assert %{resp_body: "Deleted bear 5", status_code: 200} = Router.route(conv)
    end

    for path <- ["/qwerty", "/yala/abc"], verb <- ["GET", "DELETE", "PUT", "POST"] do
      @path path
      @verb verb
      test "#{verb} #{path} returns 404" do
        conv = ServySupportTest.create_conv(@verb, @path)

        assert %{resp_body: "Resource #{@path} not found", status_code: 404} = Router.route(conv)
      end
    end

    test "GET /bears/new serves form.html" do
      conv = ServySupportTest.create_conv("GET", "/bears/new")
      assert %{resp_body: "<form" <> _rest, status_code: 200} = Router.route(conv)
    end

    test "GET /pages/about.md serves page" do
      conv = ServySupportTest.create_conv("GET", "/pages/about.md")
      assert %{resp_body: "# About\n" <> _rest, status_code: 200} = Router.route(conv)
    end

    test "GET /about serves page" do
      conv = ServySupportTest.create_conv("GET", "/about")
      assert %{resp_body: "# About\n" <> _rest, status_code: 200} = Router.route(conv)
    end

    test "GET /pages/bla.md returns 404" do
      conv = ServySupportTest.create_conv("GET", "/pages/bla.md")
      assert %{resp_body: "File not found!", status_code: 404} = Router.route(conv)
    end

    test "GET /pages/../bla.md returns 500" do
      conv = ServySupportTest.create_conv("GET", "/pages/../bla.md")

      assert %{resp_body: "Something went wrong: goes_to_parent", status_code: 500} =
               Router.route(conv)
    end

    test "GET /pages/bla.php returns 500" do
      conv = ServySupportTest.create_conv("GET", "/pages/bla.php")

      assert %{resp_body: "Something went wrong: wrong_ext", status_code: 500} =
               Router.route(conv)
    end
  end
end
