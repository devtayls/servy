defmodule Servy.KickStarter do
  use GenServer

  def start_link(_arg) do
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  @spec get_server :: any
  def get_server() do
    GenServer.call(__MODULE__, :get_server)
  end

  @spec init(:ok) :: {:ok, pid}
  def init(:ok) do
    Process.flag(:trap_exit, true)

    server_pid = start_server()

    {:ok, server_pid}
  end

  def handle_call(:get_server, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("The http server has died with reason: #{inspect(reason)}")
    server_pid = start_server()
    {:noreply, server_pid}
  end

  defp start_server() do
    IO.puts("Starting the http server...")

    port = Application.get_env(:servy, :port)
    server_pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(server_pid, :http_server)

    server_pid
  end
end
