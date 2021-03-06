# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_app_template,
  ecto_repos: [PhoenixAppTemplate.Repo]

# Configures the endpoint
config :phoenix_app_template, PhoenixAppTemplate.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yJ6d6b30ch+mYhvmHvYPg5PcJnSB/TT76SGrxzELMDGnhRchF3doNLjfJ56lTU+c",
  render_errors: [view: PhoenixAppTemplate.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixAppTemplate.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :guardian, Guardian,
  issuer: "PhoenixAppTemplate.#{Mix.env}",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: to_string(Mix.env),
  serializer: PhoenixAppTemplate.GuardianSerializer

config :ueberauth, Ueberauth,
  # base_path: "/session", # Allows to override default "/auth"
  providers: [
    google: {Ueberauth.Strategy.Google, []},
    vk: {Ueberauth.Strategy.VK, [default_scope: "email"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.VK.OAuth,
  client_id: System.get_env("VK_CLIENT_ID"),
  client_secret: System.get_env("VK_CLIENT_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
