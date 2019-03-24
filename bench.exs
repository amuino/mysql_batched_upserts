Repo.start_link()

[num_keys, time] =
  case System.argv() do
    [] -> [10_000, 60]
    [num_keys] -> [String.to_integer(num_keys), 60]
    [num_keys, seconds] -> [String.to_integer(num_keys), String.to_integer(seconds)]
    _ -> raise("too many parameters")
  end

IO.puts(
  "#{IO.ANSI.green()}Upserting #{num_keys} unique keys for #{time} seconds#{IO.ANSI.reset()}\n"
)

keys = 1..num_keys |> Enum.map(&Integer.to_string/1)

run_at = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

upsert_in_chunks = fn chunk_size, isolation ->
  keys
  |> Enum.chunk_every(chunk_size)
  |> Enum.each(fn chunk ->
    schemas =
      Enum.map(
        chunk,
        &(%BenchSchema{
            key: &1,
            value: run_at,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          }
          |> Map.delete(:__meta__)
          |> Map.delete(:__struct__))
      )

    Repo.query!("SET TRANSACTION ISOLATION LEVEL #{isolation}")

    Repo.transaction(fn ->
      Repo.insert_all(
        BenchSchema,
        schemas,
        on_conflict: :replace_all_except_primary_key
      )
    end)
  end)
end

jobs = %{
  "1x   REPEATABLE READ (default)" => fn _ -> upsert_in_chunks.(1, "REPEATABLE READ") end,
  "10x  REPEATABLE READ (default)" => fn _ -> upsert_in_chunks.(10, "REPEATABLE READ") end,
  "100x REPEATABLE READ (default)" => fn _ -> upsert_in_chunks.(100, "REPEATABLE READ") end,
  "1000x REPEATABLE READ (default)" => fn _ -> upsert_in_chunks.(1000, "REPEATABLE READ") end,
  "1x   READ UNCOMMITTED (lowest)" => fn _ -> upsert_in_chunks.(1, "READ UNCOMMITTED") end,
  "10x  READ UNCOMMITTED (lowest)" => fn _ -> upsert_in_chunks.(10, "READ UNCOMMITTED") end,
  "100x READ UNCOMMITTED (lowest)" => fn _ -> upsert_in_chunks.(100, "READ UNCOMMITTED") end,
  "1000x READ UNCOMMITTED (lowest)" => fn _ -> upsert_in_chunks.(1000, "READ UNCOMMITTED") end
}

Benchee.run(
  jobs,
  formatters: [Benchee.Formatters.Console],
  time: time,
  before_each: fn _ -> Repo.delete_all(BenchSchema) end
)
