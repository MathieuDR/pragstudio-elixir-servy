defmodule Servy.Parser do
  def parse(request) do
    [top, body] = String.split(request, "\n\n")
    [request_line | headers] = String.split(top, "\n")
    [method, path, _] = String.split(request_line, " ")
    headers = parse_headers(headers)
    params = parse_params(headers["Content-Type"], body)

    create_conv(method, path, headers, params)
  end

  def parse_headers(headers) do
    Enum.reduce(headers, %{}, fn header, acc ->
      [key, value] =
        header
        |> String.split(":", parts: 2, trim: true)
        |> Enum.map(&String.trim/1)

      Map.put(acc, key, value)
    end)
  end

  @doc """
  Parses param string in the form of `key1=value1&key2=value2` into a map with corresponding keys and values

  ## Examples
    iex> params_string = "name=Balloo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{"name" => "Balloo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/formdata", params_string)
    iex> %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

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
