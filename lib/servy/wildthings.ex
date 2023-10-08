defmodule Servy.Wildthings do
  def list_bears do
    case get_bears_from_db() do
      {:ok, bears} -> bears
      {:error, error} -> raise(error)
    end
  end

  def get_bear(id) when is_binary(id), do: id |> String.to_integer() |> get_bear

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), &(&1.id == id))
  end

  defp get_parsed_json() do
    case File.read(get_file_path()) do
      {:ok, json} -> {:ok, Poison.decode!(json)}
      _ = error -> error
    end
  end

  defp get_bears_from_db() do
    with {:ok, %{"bears" => bears}} <- get_parsed_json() do
      {:ok,
       bears
       |> Enum.map(
         &%Servy.Models.Bear{
           name: &1["name"],
           id: &1["id"],
           type: &1["type"],
           hibernating: &1 |> Map.get("hibernating", false)
         }
       )}
    end
  end

  defp get_file_path() do
    "../../db"
    |> Path.expand(__DIR__)
    |> Path.join("bears.json")
  end
end
