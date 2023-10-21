defmodule Servy.Handler do
  alias Servy.Plugins
  alias Servy.Parser
  alias Servy.Router

  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> Plugins.rewrite_id_from_query_params()
    |> Plugins.log()
    |> Router.route()
    |> Plugins.track()
    |> format_response()
  end

  def format_response(%Servy.Conv{} = conv) do
    """
    HTTP/1.1 #{conv.status_code} #{status_reason(conv.status_code)}\r
    #{create_headers(conv.resp_headers)}\r
    \r
    #{conv.resp_body}
    """
  end

  def create_headers(headers) do
    headers
    |> Enum.sort(fn {key, _}, {key2, _} ->
      cond do
        key == "Content-Type" -> true
        key2 == "Content-Type" -> false
        key == "Content-Length" -> true
      end
    end)
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
    |> Enum.join("\r\n")
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
end
