defmodule Servy.FileServer do
  @base_path Path.expand("../../pages", __DIR__)
  alias Servy.Conv

  def serve_file(page, conv) do
    case validate_page_input(page) do
      {:ok, page} ->
        retrieve_file(Path.join(@base_path, page), conv)

      {:error, reason} ->
        %Conv{conv | status_code: 500, resp_body: "Something went wrong: #{reason}"}
    end
  end

  defp retrieve_file(path, conv) do
    case File.read(path) do
      {:ok, content} -> %Conv{conv | status_code: 200, resp_body: content}
      {:error, :enoent} -> %Conv{conv | status_code: 404, resp_body: "File not found!"}
      {:error, reason} -> %Conv{conv | status_code: 500, resp_body: "File error: #{reason}"}
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
end
