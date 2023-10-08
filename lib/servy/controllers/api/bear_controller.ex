defmodule Servy.Controllers.Api.BearController do
  def index(conv) do
    json = Servy.Wildthings.list_bears() |> Poison.encode!()
    Servy.Conv.put_content(conv, json, "application/json")
  end

  def create(conv, %{"name" => name, "type" => type}) do
    Servy.Conv.put_content(conv, "Created a #{type} bear named #{name}!", "text/html", 201)
  end
end
