defmodule Repo.Migrations.CreateBenchTable do
  use Ecto.Migration

  def change do
    create table("bench") do
      add(:key, :string, size: 40)
      add(:value, :string, size: 40)
      timestamps()
    end

    create(index("bench", [:key], unique: true))
  end
end
