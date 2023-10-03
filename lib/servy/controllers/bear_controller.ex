defmodule Servy.Controllers.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Models.Bear

  def index(conv) do
    html =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_type?(&1, "Grizzly"))
      |> Enum.sort(&(&1.name <= &2.name))
      |> Enum.map(&bear_item/1)
      |> Enum.join()

    html = "<ul>#{html}</ul>"

    %Conv{conv | status_code: 200, resp_body: html}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %Conv{conv | status_code: 200, resp_body: "#{bear.name} - #{bear.type}"}
  end

  def new(conv, %{
        "name" => name,
        "type" => type
      }) do
    %Conv{conv | status_code: 201, resp_body: "Fake bear created. #{name}, a #{type} bear"}
  end

  def delete(conv, %{"id" => id}) do
    %Conv{conv | status_code: 200, resp_body: "Deleted bear #{id}"}
  end

  defp bear_item(%Bear{} = bear), do: "<li>#{bear.name} - #{bear.type}</li>"
end
