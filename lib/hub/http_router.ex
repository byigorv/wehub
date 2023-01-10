defmodule Hub.HttpRouter do
  use Plug.Router

  use Plug.ErrorHandler

  require EEx

  alias Hub.UsersHub
  alias Hub.{Users}

  plug Plug.Static,
    at: "/",
    from: :hub
  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  plug :dispatch

  EEx.function_from_file(:defp, :application_html, "lib/application.html.eex", [])

  post "/send" do
    params = conn.body_params
    body = Poison.encode!(params["message"])

    UsersHub.publish(body, params["user_ids"])
    # Users.send(body, [to: params["user_ids"]])

    # pids = Registry.select(Registry.Hub, [{{:_, :"$2", :_}, [], [:"$2"]}])
    # IO.inspect(pids)
    # Manifold.send(pids, body)
    # Registry.Hub
    # |> Registry.dispatch(Registry.Hub, fn(entries) ->
    #   for {pid, entry} <- entries do
    #     case Map.has_key?(conn.body_params["user_ids"], entry.user_id) do
    #       true ->
    #         {pid}
    #     end
    #   end
    # end)
    # |> Manifold.send(&1, body)

    data = Poison.encode!(%{status: "ok"})
    send_resp(conn, 200, data)
  end

  get "/" do
    send_resp(conn, 200, application_html())
  end

  match _ do
    send_resp(conn, 404, "404 No Found")
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    IO.inspect reason
    send_resp(conn, conn.status, "Something went wrong")
  end
end
