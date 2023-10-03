defmodule Servy.Parser do
  def parse(request) do
    [top, body] = String.split(request, "\n\n")
    [request_line | headers] = String.split(top, "\n")
    [method, path, _] = String.split(request_line, " ")
    headers = parse_headers(headers)
    params = parse_params(headers["Content-Type"], body)

    create_conv(method, path, headers, params)
  end

  def parse_headers(list, headers \\ %{})
  def parse_headers([], headers), do: headers

  def parse_headers([h | t], headers) do
    [key, value] =
      h
      |> String.split(":", parts: 2, trim: true)
      |> Enum.map(&String.trim/1)

    headers = Map.put(headers, key, value)
    parse_headers(t, headers)
  end

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  defp parse_params(_, _), do: %{}

  defp create_conv(verb, route, headers, params),
    do: %Servy.Conv{
      method: verb,
      path: route,
      resp_body: nil,
      status_code: nil,
      headers: headers,
      params: params
    }
end
