defmodule Sessions.Repo do
  use Ecto.Repo,
    otp_app: :wehub,
    adapter: Ecto.Adapters.Postgres
end

defmodule Sessions.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :string, autogenerate: false}
    end
  end
end

defmodule Sessions.Session do
  use Sessions.Schema

  schema "sessions" do
    field(:token, :string)
    field(:createat, :integer)
    field(:expiresat, :integer)
    field(:lastactivityat, :integer)
    field(:userid, :string)
    field(:deviceid, :string)
    field(:roles, :string)
    field(:isoauth, :boolean)
    field(:props, :map)
    field(:expirednotify, :boolean)
  end
end
