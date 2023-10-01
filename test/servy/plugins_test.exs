defmodule Servy.PluginsTest do
  use ExUnit.Case
  alias Servy.ServySupportTest
  alias Servy.Plugins

  describe "emojify/1" do
    for status_code <- [401, 403, 404, 500] do
      @status_code status_code
      test "#{status_code} has no emoji in resp body" do
        %{resp_body: body} =
          %{
            ServySupportTest.create_conv("GET", "/no-tada")
            | status_code: @status_code,
              resp_body: "papiot"
          }
          |> Plugins.emojify()

        assert "papiot" = body
      end
    end

    for status_code <- [200, 201] do
      @status_code status_code
      test "#{status_code} has an emoji in resp body" do
        %{resp_body: body} =
          %{
            ServySupportTest.create_conv("GET", "/tada")
            | status_code: @status_code,
              resp_body: "papiot"
          }
          |> IO.inspect()
          |> Plugins.emojify()

        assert "🎉 papiot" = body
      end
    end
  end

  describe "rewrite_id_from_query_params/1" do
    test "does not change path with no params" do
      conv = ServySupportTest.create_conv("GET", "/bears")
      assert ^conv = Plugins.rewrite_id_from_query_params(conv)
    end

    test "does not change path where params does not have id" do
      conv = ServySupportTest.create_conv("GET", "/bears?blub=9")
      assert ^conv = Plugins.rewrite_id_from_query_params(conv)
    end

    test "changes route when id is present" do
      conv = ServySupportTest.create_conv("GET", "/bears?id=9")
      assert %{path: "/bears/9"} = Plugins.rewrite_id_from_query_params(conv)
    end

    test "changes route when id is not first param" do
      conv = ServySupportTest.create_conv("GET", "/bears?blub=8&id=9")
      assert %{path: "/bears/9"} = Plugins.rewrite_id_from_query_params(conv)
    end
  end

  describe "rewrite_path/1" do
    test "Does not change on random string" do
      conv = ServySupportTest.create_conv("GET", "/bears")
      assert ^conv = Plugins.rewrite_path(conv)
    end

    test "Does change on /wildlife" do
      conv = ServySupportTest.create_conv("GET", "/wildlife")
      assert %{path: "/wildthings"} = Plugins.rewrite_path(conv)
    end
  end
end
