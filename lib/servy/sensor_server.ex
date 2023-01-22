defmodule Servy.SensorServer do
  use GenServer

  @name :sensor_server

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.seconds(15)
  end

  def start_link(interval) do
    IO.puts("Starting the sensor server with interval #{interval} refresh...")
    GenServer.start_link(__MODULE__, %State{refresh_interval: interval}, name: @name)
  end

  def get_sensor_data() do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(interval) do
    GenServer.cast(@name, {:set_refresh_interval, interval})
  end

  def init(state) do
    sensor_data = run_tasks_to_get_sensor_data()

    initial_state = %{state | sensor_data: sensor_data}

    schedule_refresh(initial_state.refresh_interval)

    {:ok, initial_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_cast({:set_refresh_interval, interval}, state) do
    new_state = %{state | refresh_interval: interval}
    schedule_refresh(interval)
    {:noreply, new_state}
  end

  def handle_info(:refresh, state) do
    IO.puts("Refreshing the cache...")
    sensor_data = run_tasks_to_get_sensor_data()
    new_state = %{state | sensor_data: sensor_data}
    schedule_refresh(state.refresh_interval)
    {:noreply, new_state}
  end

  defp schedule_refresh(interval) do
    IO.puts("Scheduling refresh in #{interval} seconds...")
    Process.send_after(self(), :refresh, :timer.seconds(interval))
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts("Running tasks to get sensor data...")

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
