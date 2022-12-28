defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
  %{conv | path: "/wildthings"}
 end

 def rewrite_path(conv), do: conv

 def normalize_path_params(conv) do
   cond do
    String.contains?(conv.path, "?id=") ->
      map = Regex.named_captures(~r"\/(?<path>\w+)\?id=(?<value>\d)", conv.path)
      %{conv | path: "/#{map["path"]}/#{map["value"]}"}
    true -> conv
   end
 end

  def track(%Conv{status: 404, path: path} = conv) do
  Logger.warn("No route for #{path}")
  conv
 end

 def track(%Conv{} = conv), do: conv

  def log(%Conv{} = conv), do: IO.inspect(conv)

   @spec decorate_response(any) :: any
 def decorate_response(%Conv{status: 200} = conv) do
    %{ conv | resp_body: "👏 #{conv.resp_body} 👏" }
 end

 def decorate_response(%Conv{} = conv), do: conv
end
