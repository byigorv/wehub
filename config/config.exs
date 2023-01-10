import Config

config :wehub, Sessions.Repo,
  database: "mattermost_test",
  username: "mmuser",
  password: "mostest",
  hostname: "localhost"
