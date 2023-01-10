defmodule Hub.UsersHub do
  alias Hub.UsersStore
  use GenServer

  defstruct conns: []
  # defstruct conns: %{}

  def register(web_conn) do
    GenServer.call(:global.whereis_name(:users_hub), {:register, web_conn})
  end

  def publish(message, user_ids) do
    GenServer.cast(:global.whereis_name(:users_hub), {:publish, message, user_ids})
  end

  def handle_call({:register, web_conn}, _from, state) do
    UsersStore.insert(web_conn.user_id, web_conn.pid)
    {:reply, :ok, %__MODULE__{state | conns: [web_conn | state.conns]} }
  end

  def handle_cast({:publish, message, user_ids}, state) do
    Enum.each(user_ids, fn user_id ->
      values = UsersStore.find(user_id)
      IO.puts("UsersStore.find #{user_id}")
      IO.inspect(values)
    end)
    Manifold.send(Enum.map(state.conns, fn c -> c.pid end), message)
    {:noreply, state}
  end

  def init(state) do
    IO.puts("init")
    {:ok, state}
  end

  def start_link(_) do
    pid = case GenServer.start_link(__MODULE__, %__MODULE__{}, name: {:global, :users_hub}) do
      {:ok, pid} ->
        pid
      {:error, {:already_started, pid}} ->
        IO.puts("already started")
        pid
    end

    :global.register_name(:users_hub, pid)

    Process.link(pid)
    {:ok, pid}
  end
end
