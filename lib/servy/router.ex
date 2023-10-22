defmodule Servy.Router do
  alias Servy.FileServer
  alias Servy.Conv
  alias Servy.Controllers.BearController
  alias Servy.Controllers.PledgeController
  alias Servy.Videocam

  def route(%Conv{path: "/about", method: "GET"} = conv) do
    FileServer.serve_file("about.md", conv)
  end

  def route(%Conv{path: "/bears/new", method: "GET"} = conv) do
    FileServer.serve_file("form.html", conv)
  end

  def route(%Conv{path: "/pledges", method: "POST"} = conv) do
    PledgeController.create(conv, conv.params)
  end

  def route(%Conv{path: "/404s", method: "GET"} = conv) do
    Conv.put_content(conv, inspect(Servy.Http404Counter.get_counts()))
  end

  def route(%Conv{path: "/pledges", method: "GET"} = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{path: "/pages/sensors", method: "GET"} = conv) do
    {snapshots, location} = get_sensor_data()

    content =
      "../templates"
      |> Path.expand(__DIR__)
      |> Path.join("sensors.eex")
      |> EEx.eval_file(images: snapshots, location: location)

    Conv.put_content(conv, content)
  end

  def route(%Conv{path: "/pages/" <> page, method: "GET"} = conv) do
    FileServer.serve_file(page, conv)
  end

  def route(%Conv{path: "/error", method: "GET"} = _conv) do
    raise "Kablomie"
  end

  def route(%Conv{path: "/sensors", method: "GET"} = conv) do
    {time, result} = :timer.tc(fn -> get_sensor_data() end)
    Conv.put_content(conv, inspect({time / 1000, result}))
  end

  def route(%Conv{path: "/hibernate/" <> time, method: "GET"} = conv) do
    time |> String.to_integer() |> :timer.sleep()
    Conv.put_content(conv, "Awake", "plain/text")
  end

  def route(%Conv{path: "/wildthings", method: "GET"} = conv) do
    Conv.put_content(conv, "Bears, Lions, Tigers")
  end

  def route(%Conv{path: "/api/bears", method: "GET"} = conv) do
    Servy.Controllers.Api.BearController.index(conv)
  end

  def route(%Conv{path: "/api/bears", method: "POST"} = conv) do
    Servy.Controllers.Api.BearController.create(conv, conv.params)
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
    Conv.put_content(conv, "Resource #{path} not found", "text/html", 404)
  end

  defp get_sensor_data do
    Servy.SensorServer.get_sensor_data()
  end
end
