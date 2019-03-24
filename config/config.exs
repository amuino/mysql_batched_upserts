# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :mysql_batched_upserts, ecto_repos: [Repo]

config :mysql_batched_upserts, Repo,
  database: "mysql_batched_upserts",
  username: "root",
  hostname: "localhost",
  log: false
