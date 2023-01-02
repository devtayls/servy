defmodule Servy.Handler do
  require Logger

  @moduledoc """
  Transforms a request into a response
  """

  alias Servy.Conv
  alias Servy.BearController

  import Servy.Plugins, only: [rewrite_path: 1, normalize_path_params: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @pages_path Path.expand("pages", File.cwd!())

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> normalize_path_params
    |> log
    |> route
    |> put_content_length
    |> track
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No route for #{path}"}
  end

  def put_resp_content_type(%Conv{} = conv, content_type) do
    %{conv | resp_headers: Map.put(conv.resp_headers, "Content-Type", content_type)}
  end

  def put_content_length(%Conv{} = conv) do
    %{
      conv
      | resp_headers: Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    }
  end

  def format_response_headers(%Conv{} = conv) do
    Enum.map(conv.resp_headers, fn {key, value} -> "#{key}: #{value}" end)
    |> Enum.sort(:desc)
    |> Enum.join("\r")
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end
end

# request = """
# GET /wildthings HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# """

# response = Servy.Handler.handle(request)

# IO.puts response
