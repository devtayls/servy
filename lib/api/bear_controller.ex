defmodule Servy.Api.BearController do
  alias Servy.Handler

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    conv = Handler.put_resp_content_type(conv, "application/json")

    %{conv | status: 200, resp_body: json}
  end
end
