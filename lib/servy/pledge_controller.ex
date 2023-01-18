defmodule Servy.PledgeController do
  alias Servy.PledgeServer

  def create(conv, %{"amount" => amount, "name" => name} = _params) do
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{conv | status: 201, resp_body: "Created a pledge of $#{amount} from #{name}"}
  end

  def index(conv) do
    pledges = PledgeServer.recent_pledges()

    %{conv | status: 200, resp_body: inspect(pledges)}
  end
end
