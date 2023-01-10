defmodule Hub.App do
  def start_link() do

    port = System.get_env("PORT")
    port = String.to_integer(port)
    IO.puts(port)

    children = [
      {Cluster.Supervisor, [
        [
          hub: [
            strategy: Cluster.Strategy.Gossip,
            # config: [hosts: [
            #   :"n1@127.0.0.1",
            #   :"n2@127.0.0.1",
            # ]],
          ]
        ],
        [name: Hub.App.ClusterSupervisor]
      ]},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Hub.HttpRouter,
        options: [
          dispatch: dispatch(),
          port: port,
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Hub
      ),
      Sessions.Repo,
      Hub.Users,
      Hub.UsersHub,
      Hub.UsersStore,
      {Registry, keys: :unique, name: Hub.UserConnsRegistry},
    ]

    opts = [strategy: :one_for_one, name: Hub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
        [
          {"/api/v4/websocket", Hub.WsHandler, []},
          {:_, Plug.Cowboy.Handler, {Hub.HttpRouter, []}}
        ]
      }
    ]
  end
end
