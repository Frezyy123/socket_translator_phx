defmodule SocketTranslatorPhx.Repo do
  use Ecto.Repo,
    otp_app: :socket_translator_phx,
    adapter: Ecto.Adapters.Postgres
end
