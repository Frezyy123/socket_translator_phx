use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :socket_translator_phx, SocketTranslatorPhx.Repo,
  username: "postgres",
  password: "postgres",
  database: "socket_translator_phx_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :socket_translator_phx, SocketTranslatorPhxWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :socket_translator_phx, SocketTranslatorPhx.Translator,
  api_url: "localhost:5000/translate/v2/translate"

config :socket_translator_phx, SocketTranslatorPhx.CacheWorker,
  time_to_live: 3
