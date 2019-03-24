defmodule BenchSchema do
  use Ecto.Schema

  schema "bench" do
    field(:key, :string)
    field(:value, :string)
    timestamps
  end
end
