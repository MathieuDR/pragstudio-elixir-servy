defmodule Servy.Router do
  alias Servy.FileServer
  alias Servy.Conv

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

  def route(%Conv{path: "/bears", method: "GET"} = conv) do
    %Conv{conv | status_code: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%Conv{path: "/bears/" <> id, method: "GET"} = conv) do
    %Conv{conv | status_code: 200, resp_body: "Bear #{id}"}
  end

  def route(%Conv{path: "/bears/" <> id, method: "DELETE"} = conv) do
    %Conv{conv | status_code: 200, resp_body: "Deleted bear #{id}"}
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | status_code: 404, resp_body: "Resource #{path} not found"}
  end
end
