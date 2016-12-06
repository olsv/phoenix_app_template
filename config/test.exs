use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_app_template, PhoenixAppTemplate.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :comeonin, bcrypt_log_rounds: 4

# Configure your database
config :phoenix_app_template, PhoenixAppTemplate.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "phoenix_app_template_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
