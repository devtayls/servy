defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter

  def start do
    IO.puts("Starting FourOhFourCounter")
    pid = spawn(__MODULE__, :listen_loop, [%{}])

    Process.register(pid, :four_oh_four_counter)

    pid
  end

  def count_404(path) do
    send(@name, {self(), :count_404, path})

    receive do
      {:count_404, value} -> value
    end
  end

  def get_counts() do
    send(@name, {self(), :get_counts})

    receive do
      {:get_counts, counts} -> counts
    end
  end

  def get_count(path) do
    send(@name, {self(), :get_count, path})

    receive do
      {:get_count, value} -> value
    end
  end

  # Server

  def listen_loop(state) do
    receive do
      {sender, :count_404, path} ->
        new_state = Map.update(state, path, 1, fn count -> count + 1 end)
        # increase the count
        send(sender, {:count_404, Map.get(new_state, path)})

        listen_loop(new_state)

      {sender, :get_counts} ->
        send(sender, {:get_counts, state})
        listen_loop(state)

      {sender, :get_count, path} ->
        count = Map.get(state, path, 0)
        send(sender, {:get_count, count})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end
end
