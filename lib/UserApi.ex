defmodule UserApi do
  alias HTTPoison
  alias Poison

  def query(id) do
    case HTTPoison.get("https://jsonplaceholder.typicode.com/users/" <> id) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Poison.Parser.parse!(%{}) |> get_in(["address", "city"])}

      {:ok, %HTTPoison.Response{status_code: _code, body: body}} ->
        {:error, body |> Poison.Parser.parse!(%{}) |> get_in(["message"])}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
