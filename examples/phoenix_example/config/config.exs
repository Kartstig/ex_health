# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_example,
  ecto_repos: [PhoenixExample.Repo]

# Configures the endpoint
config :phoenix_example, PhoenixExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZxgEdDChD5hx0IqsZbY3R+BG4TBpupXJufUvpq39Eep1FBC/OJxnWvDZA3eT++yR",
  render_errors: [view: PhoenixExampleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixExample.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :ex_health,
  module: PhoenixExampleWeb.HealthChecks,
  interval_ms: 1000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
