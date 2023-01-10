defmodule Hub.Users do
  use Supervisor
  use GenServer

  alias Hub.{UserConns, UserConnsRegistry}

  defstruct web_conns: []

  def register(web_conn) do
    case find(web_conn.user_id) do
      nil ->
        case start(web_conn.user_id) do
          {:ok, pid} ->
            IO.puts("new register")
            UserConns.register(pid, web_conn)
            {:ok}
          {:error, {:already_started, pid}} ->
            IO.puts("already registerd")
            UserConns.register(pid, web_conn)
            {:ok}
        end
      pid ->
        IO.puts("register")
        UserConns.register(pid, web_conn)
        {:ok}
    end
  end

  def send(message, [to: user_ids]) do
    Enum.each(user_ids, fn user_id ->
      case find(user_id) do
        nil ->
          IO.puts("not found")
          {:error, :not_found}
        pid ->
          IO.puts("found")
          UserConns.publish(pid, message)
      end
    end)
  end

  def start_link(_opts) do
    :global.trans({__MODULE__, :users}, fn ->
      case Supervisor.start_link(__MODULE__, [], name: {:global, :users}) do
        {:ok, pid} ->
          :global.register_name(:users, pid)
          IO.puts("started new Supervisor")
          {:ok, pid}
        {:error, {:already_started, pid}} ->
          IO.puts("started Supervisor")
          Process.monitor(pid)
          {:ok, pid}
      end
    end)

    
    # GenServer.start_link(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  defp start(user_id) do
    name = {:via, Registry, {UserConnsRegistry, user_id}}

    :global.trans({__MODULE__, :users}, fn ->
      case Supervisor.start_child(:global.whereis_name(:users), [name]) do
        {:ok, pid} ->
          IO.puts("new start_child")
          # :global.register_name(name, pid)
          users = FastGlobal.get(:users, %{})
          Map.put(users, user_id, pid)
          IO.inspect(users)
          FastGlobal.put(:users, users)
          {:ok, pid}
        {:error, {:already_started, pid}} ->
          IO.puts("start_child")
          Process.monitor(pid)
          {:ok, pid}
      end
    end)

  end

  def init(_) do
    children = [
      worker(UserConns, [])
    ]

    opts = [strategy: :simple_one_for_one]
    Supervisor.init(children, opts)
  end

  defp find(user_id) do
    users = FastGlobal.get(:users, %{})
    IO.puts("find")
    IO.inspect(users)
    Map.get(users, user_id)
  #   case Registry.lookup(:global.whereis_name(UserConnsRegistry), user_id) do
  #     [] -> nil
  #     [{pid, _}] -> pid
  #  end
  end


  ##

  def handle_call({:register, web_conn}, _from, state) do
    {:reply, :ok, %__MODULE__{state | web_conns: [web_conn | state.web_conns]} }
  end

  def handle_cast({:publish, message, user_ids}, state) do

  end
end
