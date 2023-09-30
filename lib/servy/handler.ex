defmodule Servy.Handler do
  alias Servy.Plugins
  alias Servy.Router

  def handle(request) do
    request
    |> parse()
    |> Plugins.rewrite_path()
    |> Plugins.rewrite_id_from_query_params()
    |> Plugins.log()
    |> Router.route()
    |> Plugins.emojify()
    |> Plugins.track()
    |> format_response()
  end

  def parse(request) do
    request
    |> String.split("\n")
    |> List.first()
    |> String.split(" ")
    |> create_conv()
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

  defp create_conv([verb, route, _version]),
    do: %{method: verb, path: route, resp_body: nil, status: nil}
end
