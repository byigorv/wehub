defmodule Hub.UsersStore do
  use GenServer

  @table_name :users_store

  def insert(key, value) do
    GenServer.cast(__MODULE__, {:insert, {key, value}})
  end

  def find(key) do
    GenServer.call(__MODULE__, {:find, key})
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_state) do
    pid = :ets.new(@table_name, [:ordered_set, read_concurrency: true])
    {:ok, pid}
  end

  def handle_cast({:insert, {key, val}}, pid) do
    IO.puts("UsersStore.insert, key: #{key}")
    :ets.insert_new(pid, {key, val})
    {:noreply, pid}
  end

  def handle_cast({:delete, key}, pid) do
    :ets.delete(pid, key)
    {:noreply, pid}
  end

  def handle_call({:find, key}, _from, pid) do
    IO.puts("UsersStore.find, key: #{key}")
    val = :ets.lookup(pid, key)
    {:reply, val, pid}
  end
end
