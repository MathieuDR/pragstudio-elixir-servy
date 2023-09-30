defmodule Servy.Plugins do
  require Logger

  def rewrite_path(%{path: "/wildlife"} = conv), do: %{conv | path: "/wildthings"}
  def rewrite_path(conv), do: conv

  def emojify(%{status: code, resp_body: body} = conv) when code in [200, 201] do
    %{conv | resp_body: "🎉 " <> body}
  end

  def emojify(conv), do: conv

  def log(conv) do
    Logger.notice(conv)
    conv
  end

  def track(%{status: 404, path: path} = conv) do
    Logger.warn("#{path} not found")
    conv
  end

  def track(conv), do: conv

  def rewrite_id_from_query_params(%{path: path} = conv) do
    with {base_path, params} <- extract_params(path),
         id when not is_nil(id) <- params["id"] do
      %{conv | path: "#{base_path}/#{id}"}
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
