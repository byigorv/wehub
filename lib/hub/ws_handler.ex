defmodule Hub.WsHandler do
  @behaviour :cowboy_websocket

  alias Hub.UsersHub
  alias Hub.{Users}

  @impl true
  def init(req, _state) do
    IO.puts("init")

    query = URI.decode_query(req.qs)
    IO.inspect(query)

    state = %{
      token: query["token"]
    }

    {:cowboy_websocket, req, state}
  end

  @impl true
  def websocket_init(state) do
    case get_session(state.token) do
      {:error, reason} ->
        IO.puts("can't get session #{reason}")
        {:reply, {:close, 1006, nil}, state}
      {:ok, session} ->

        conn_id = UUID.uuid4(:hex)
        web_conn = %{
          user_id: session.userid,
          conn_id: conn_id,
          pid:     self(),
        }

        UsersHub.register(web_conn)
        message = %{event: "hello", data: %{connection_id: conn_id}}
        text = Poison.encode!(message)
        {:reply, {:text, text}, state}
        # case Users.register(web_conn) do
        #   {:ok} ->
        #     message = %{event: "hello", data: %{connection_id: conn_id}}

        #     text = Poison.encode!(message)
        #     {:reply, {:text, text}, state}
        #   {:error, reason} ->
        #     IO.puts("error: #{reason}")
        #     {:reply, {:close, 1006, nil}, state}
        # end
    end
  end

  def get_session(token) do
    import Ecto.Query
    alias Sessions.{Repo, Session}

    case token do
      "" ->
        {:error, "token is empty"}
      _ ->
        session = Repo.one(from s in Session, where: s.token == ^token)
        case session do
           nil ->
            {:error, "token not found"}
            _ ->
            {:ok, session}
        end
    end
  end

  @impl true
  def websocket_handle({:text, json}, state) do
    payload = Poison.decode!(json)
    message = payload["data"]["message"]

    IO.puts("handle `#{message}`")

    out = Poison.encode!(%{event: "posted", data: %{message: message}})

    {:reply, {:text, out}, state}
  end

  @impl true
  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end
end
