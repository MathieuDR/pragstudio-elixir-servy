defmodule Servy.Router do
  alias Servy.FileServer

  def route(%{path: "/about", method: "GET"} = conv) do
    FileServer.serve_file("about.md", conv)
  end

  def route(%{path: "/bears/new", method: "GET"} = conv) do
    FileServer.serve_file("form.html", conv)
  end

  def route(%{path: "/pages/" <> page, method: "GET"} = conv) do
    FileServer.serve_file(page, conv)
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
end
