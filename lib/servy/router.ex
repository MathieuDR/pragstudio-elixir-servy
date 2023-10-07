defmodule Servy.Router do
  alias Servy.FileServer
  alias Servy.Conv
  alias Servy.Controllers.BearController

  def route(%Conv{path: "/about", method: "GET"} = conv) do
    FileServer.serve_file("about.md", conv)
  end

  def route(%Conv{path: "/bears/new", method: "GET"} = conv) do
    FileServer.serve_file("form.html", conv)
  end

  def route(%Conv{path: "/pages/" <> page, method: "GET"} = conv) do
    FileServer.serve_file(page, conv)
  end

  def route(%Conv{path: "/wildthings", method: "GET"} = conv) do
    %Conv{conv | status_code: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{path: "/api/bears", method: "GET"} = conv) do
    Servy.Controllers.Api.BearController.index(conv)
  end

  def route(%Conv{path: "/bears", method: "GET"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{path: "/bears/" <> id, method: "GET"} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{path: "/bears/" <> id, method: "DELETE"} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(
        %Conv{
          path: "/bears/new",
          method: "POST"
        } = conv
      ) do
    BearController.new(conv, conv.params)
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | status_code: 404, resp_body: "Resource #{path} not found"}
  end
end
