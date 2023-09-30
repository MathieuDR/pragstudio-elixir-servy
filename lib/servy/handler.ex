defmodule Servy.Handler do
  require Logger

  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> rewrite_id_from_query_params()
    |> log()
    |> route()
    |> emojify()
    |> track()
    |> format_response()
  end

  def parse(request) do
    request
    |> String.split("\n")
    |> List.first()
    |> String.split(" ")
    |> create_conv()
  end

  def rewrite_path(%{path: "/wildlife"} = conv), do: %{conv | path: "/wildthings"}
  def rewrite_path(conv), do: conv

  def rewrite_id_from_query_params(%{path: path} = conv) do
    with {base_path, params} <- extract_params(path),
         id when not is_nil(id) <- params["id"] do
      %{conv | path: "#{base_path}/#{id}"}
    else
      _ -> conv
    end
  end

  def emojify(%{status: code, resp_body: body} = conv) when code in [200, 201] do
    %{conv | resp_body: "🎉 " <> body}
  end

  def emojify(conv), do: conv

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

  def track(%{status: 404, path: path} = conv) do
    Logger.warn("#{path} not found")
    conv
  end

  def track(conv), do: conv

  @base_path Path.expand("../../pages", __DIR__)
  def route(%{path: "/about", method: "GET"} = conv) do
    serve_file(Path.join(@base_path, "about.md"), conv)
  end

  def route(%{path: "/bears/new", method: "GET"} = conv) do
    serve_file(Path.join(@base_path, "form.html"), conv)
  end

  def route(%{path: "/pages/" <> page, method: "GET"} = conv) do
    case validate_page_input(page) do
      {:ok, page} -> serve_file(Path.join(@base_path, page), conv)
      {:error, reason} -> %{conv | status: 500, resp_body: "Something went wrong: #{reason}"}
    end
  end

  def route(%{path: "/wildthings", method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{path: "/bears", method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{path: "/bears/" <> id, method: "GET"} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{path: "/bears/" <> id, method: "DELETE"} = conv) do
    %{conv | status: 200, resp_body: "Deleted bear #{id}"}
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "Resource #{path} not found"}
  end

  defp validate_page_input(page) do
    with :ok <- is_correct_extension(page, [".md", ".html"]),
         :ok <- does_not_go_to_parent(page) do
      {:ok, page}
    end
  end

  defp is_correct_extension(page, extensions) do
    Enum.map(extensions, &String.ends_with?(page, &1))
    |> Enum.member?(true)
    |> case do
      true -> :ok
      _ -> {:error, :wrong_ext}
    end
  end

  defp does_not_go_to_parent(page) do
    String.contains?(page, "../")
    |> case do
      true -> {:error, :goes_to_parent}
      false -> :ok
    end
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp serve_file(path, conv) do
    case File.read(path) do
      {:ok, content} -> %{conv | status: 200, resp_body: content}
      {:error, :enoent} -> %{conv | status: 404, resp_body: "File not found!"}
      {:error, reason} -> %{conv | status: 500, resp_body: "File error: #{reason}"}
    end
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

  defp log(conv) do
    Logger.notice(conv)
    conv
  end

  defp create_conv([verb, route, _version]),
    do: %{method: verb, path: route, resp_body: nil, status: nil}
end
