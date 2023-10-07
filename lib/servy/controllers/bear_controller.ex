defmodule Servy.Controllers.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Models.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.sort(&(&1.name <= &2.name))

    render(conv, "index.eex", bears: items)
  end

  def show(conv, %{"id" => id}), do: render(conv, "show.eex", bear: Wildthings.get_bear(id))

  def new(conv, %{
        "name" => name,
        "type" => type
      }) do
    %Conv{conv | status_code: 201, resp_body: "Fake bear created. #{name}, a #{type} bear"}
  end

  def delete(conv, %{"id" => id}) do
    %Conv{conv | status_code: 200, resp_body: "Deleted bear #{id}"}
  end

  defp render(conv, template, bindings \\ []) do
    content = @templates_path |> Path.join(template) |> EEx.eval_file(bindings)

    %Conv{conv | status_code: 200, resp_body: content}
  end
end
