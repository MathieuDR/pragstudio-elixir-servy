defmodule Servy.Controllers.BearController do
  alias Servy.Conv

  def index(conv) do
    %Conv{conv | status_code: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def show(conv, id) do
    %Conv{conv | status_code: 200, resp_body: "Bear #{id}"}
  end

  def new(
        %Conv{
          path: "/bears/new",
          method: "POST",
          params: %{
            "name" => name,
            "type" => type
          }
        } = conv
      ) do
    %Conv{conv | status_code: 201, resp_body: "Fake bear created. #{name}, a #{type} bear"}
  end

  def delete(conv, id) do
    %Conv{conv | status_code: 200, resp_body: "Deleted bear #{id}"}
  end
end
