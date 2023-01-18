defmodule Servy.PledgeController do
  alias Servy.PledgeServer
  import Servy.View

  def create(conv, %{"amount" => amount, "name" => name} = _params) do
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{conv | status: 201, resp_body: "Created a pledge of $#{amount} from #{name}"}
  end

  def index(conv) do
    pledges = PledgeServer.recent_pledges()

    render(conv, "recent_pledges.eex", pledges: pledges)
    # %{conv | status: 200, resp_body: inspect(pledges)}
  end

  def new(conv) do
    render(conv, "new_pledge.eex")
  end
end
