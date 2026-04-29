defmodule Symphony.Repo do
  use Ecto.Repo,
    otp_app: :symphony,
    adapter: Ecto.Adapters.SQLite3
end
