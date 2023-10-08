defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv), do: %Conv{conv | path: "/wildthings"}
  def rewrite_path(conv), do: conv

  def emojify(
        %Conv{status_code: code, resp_body: body, resp_headers: %{"Content-Type" => "text/html"}} =
          conv
      )
      when code in [200, 201] do
    Conv.put_content(conv, "🎉 " <> body, "text/html", code)
  end

  def emojify(conv), do: conv

  def log(conv) do
    if Mix.env() == :dev do
      IO.inspect(conv)
    end

    conv
  end

  def track(%Conv{status_code: 404, path: path} = conv) do
    if Mix.env() != :test do
      Logger.warn("#{path} not found")
    end

    conv
  end

  def track(conv), do: conv

  def rewrite_id_from_query_params(%Conv{path: path} = conv) do
    with {base_path, params} <- extract_params(path),
         id when not is_nil(id) <- params["id"] do
      %Conv{conv | path: "#{base_path}/#{id}"}
    else
      _ -> conv
    end
  end

  defp extract_params(path) do
    case String.split(path, "?", trim: true, parts: 2) do
      [base, params] -> {base, parse_params(params)}
      [base] -> {base, nil}
    end
  end

  defp parse_params(params) do
    String.split(params, "&", trim: true)
    |> Enum.map(&String.split(&1, "=", trim: true, parts: 2))
    |> Enum.reduce(%{}, fn [key, value], acc -> Map.put(acc, key, value) end)
  end
end
