defmodule Servy.FourOhFourCounter do
  use GenServer

  @name :four_oh_four_counter

  def start_link(_arg) do
    IO.puts("Starting FourOhFourCounter")
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  @spec count_404(any) :: any
  def count_404(path) do
    GenServer.cast(@name, {:count_404, path})
  end

  def reset() do
    GenServer.cast(@name, :reset)
  end

  def get_counts() do
    GenServer.call(@name, :get_counts)
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  # Server

  def handle_cast({:count_404, path}, state) do
    new_state = Map.update(state, path, 1, fn count -> count + 1 end)
    {:noreply, new_state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end
end
