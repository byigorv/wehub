defmodule Hub.UserConns do
  use GenServer

  defstruct conns: []

  def init(state) do
    {:ok, state}
  end

  def start_link(name) do
    pid = case GenServer.start_link(__MODULE__, %__MODULE__{}, name: {:global, name}) do
      {:ok, pid} ->
        pid
      {:error, {:already_started, pid}} ->
        pid
    end

    IO.puts("Process.monitor")

    Process.monitor(pid)
    {:ok, pid}
  end

  def register(pid, web_conn) do
    GenServer.call(pid, {:register, web_conn})
  end

  def publish(pid, message) do
    IO.puts("publish")
    GenServer.cast(pid, {:publish, message})
  end

  def handle_call({:register, web_conn}, _from, state) do
    IO.puts("handle_call(register)")
    {:reply, :ok, %__MODULE__{state | conns: [web_conn | state.conns]} }
  end

  def handle_cast({:publish, message}, state) do
    Manifold.send(Enum.map(state.conns, fn c -> c.pid end), message)

    # Enum.each(state.conns, &Kernel.send(&1.pid, message))
    {:noreply, state}
  end
end
