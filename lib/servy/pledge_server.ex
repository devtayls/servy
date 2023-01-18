defmodule Servy.PledgeServer do
  @name :pledge_server

  # Client Interface Functions
  def start(initial_state \\ []) do
    IO.puts("Starting PledgeServer")
    pid = spawn(__MODULE__, :listen_loop, [initial_state])

    Process.register(pid, :pledge_server)

    pid
  end

  def create_pledge(name, amount) do
    send(@name, {self(), @name, name, amount})

    receive do
      {:response, id} -> id
    end
  end

  def recent_pledges() do
    send(@name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged() do
    send(@name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # Server
  def listen_loop(state) do
    IO.puts("\n ... Waiting for a message ...")

    receive do
      {sender, @name, name, amount} ->
        IO.puts("#{name} pledged $#{amount}")

        {:ok, id} = send_pledge_to_service(name, amount)

        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]

        # IO.puts("New state: #{inspect(new_state)}")
        send(sender, {:response, id})

        listen_loop(new_state)

      {sender, :recent_pledges} ->
        IO.puts("Sent recent pledges to #{inspect(sender)}")

        send(sender, {:response, state})

        listen_loop(state)

      {sender, :total_pledged} ->
        IO.puts("Sent total pledged to #{inspect(sender)}")

        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()

        send(sender, {:response, total})

        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")

        listen_loop(state)
    end
  end

  # Mock implementation, simply returns a random ID
  def send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer

pid = PledgeServer.start()

IO.inspect(PledgeServer.create_pledge("larry", 10))
IO.inspect(PledgeServer.create_pledge("moe", 20))
IO.inspect(PledgeServer.create_pledge("curly", 30))
IO.inspect(PledgeServer.create_pledge("daisy", 40))
IO.inspect(PledgeServer.create_pledge("grace", 50))

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledged())
