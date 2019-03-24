defmodule MysqlBatchedUpserts.MixProject do
  use Mix.Project

  def project do
    [
      app: :mysql_batched_upserts,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, ">= 3.0.7"},
      {:ecto_sql, ">= 3.0.5"},
      {:mariaex, "~> 0.9.1"},
      # Benchmarks
      {:benchee, "~> 0.11.0"},
      {:benchee_json, "~> 0.4.0"}
    ]
  end
end
