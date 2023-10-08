defmodule Servy.FileServer do
  @base_path Path.expand("../../pages", __DIR__)
  alias Servy.Conv

  def serve_file(page, conv) do
    case validate_page_input(page) do
      {:ok, page} ->
        retrieve_file(Path.join(@base_path, page), conv)

      {:error, reason} ->
        Conv.put_content(conv, "Something went wrong: #{reason}", "text/html", 500)
    end
  end

  defp retrieve_file(path, conv) do
    extension = Path.extname(path)

    case File.read(path) do
      {:ok, content} ->
        Conv.put_content(conv, parse_content(extension, content), "text/html", 200)

      {:error, :enoent} ->
        Conv.put_content(conv, "File not found!", "text/html", 404)

      {:error, reason} ->
        Conv.put_content(conv, "File error: #{reason}", "text/html", 500)
    end
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

  defp parse_content(extension, content)
  defp parse_content(".md", content), do: Earmark.as_html!(content)
  defp parse_content(_, content), do: content
end
