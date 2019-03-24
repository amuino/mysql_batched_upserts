defmodule Repo do
  use Ecto.Repo,
    otp_app: :mysql_batched_upserts,
    adapter: Ecto.Adapters.MySQL
end
