defmodule SecondApps.Repo do
  use Ecto.Repo,
    otp_app: :second_apps,
    adapter: Ecto.Adapters.Postgres
end
