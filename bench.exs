Repo.start_link()

keys = 1..1_000_000 |> Enum.map(&Integer.to_string/1)

run_at = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

upsert_1_by_1 = fn isolation ->
  keys
  |> Enum.each(fn key ->
    Repo.query!("SET TRANSACTION ISOLATION LEVEL #{isolation}")

    Repo.transaction(fn ->
      Repo.insert(
        %BenchSchema{key: key, value: run_at},
        on_conflict: :replace_all_except_primary_key
      )
    end)
  end)
end

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
  "no chunks REPEATABLE READ (default)" => fn -> upsert_1_by_1.("REPEATABLE READ") end,
  "no chunks READ UNCOMMITTED (lowest)" => fn -> upsert_1_by_1.("READ UNCOMMITTED") end,
  "1x   REPEATABLE READ (default)" => fn -> upsert_in_chunks.(1, "REPEATABLE READ") end,
  "10x  REPEATABLE READ (default)" => fn -> upsert_in_chunks.(10, "REPEATABLE READ") end,
  "100x REPEATABLE READ (default)" => fn -> upsert_in_chunks.(100, "REPEATABLE READ") end,
  "1000x REPEATABLE READ (default)" => fn -> upsert_in_chunks.(1000, "REPEATABLE READ") end,
  "1x   READ UNCOMMITTED (lowest)" => fn -> upsert_in_chunks.(1, "READ UNCOMMITTED") end,
  "10x  READ UNCOMMITTED (lowest)" => fn -> upsert_in_chunks.(10, "READ UNCOMMITTED") end,
  "100x READ UNCOMMITTED (lowest)" => fn -> upsert_in_chunks.(100, "READ UNCOMMITTED") end,
  "1000x READ UNCOMMITTED (lowest)" => fn -> upsert_in_chunks.(1000, "READ UNCOMMITTED") end
}

Benchee.run(jobs, formatters: [Benchee.Formatters.Console], time: 10 * 60)

IO.inspect(Repo.query!("select count(*) from bench"))
