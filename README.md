# MysqlBatchedUpserts

A set of benchmarks measuring the effect of:
- batch size
- transaction isolation level

when performing *upserts* with [`Repo.insert_all ..., on_conflict: :replace_all_except_primary_key`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:insert_all/3)

## The benchmark

### Setup
The benchmark is using [`benchee`](https://github.com/bencheeorg/benchee) to measure the performance of _upserting_ 1 million rows. Benchmarks for each scenario are run for 10 minutes.

Total runtime is above 1h 30m.

### Results
For the default benchmark (10.000)

- Isolation level does not seem to have much an impact
- Larger batch sizes improve performance, but the difference between 100 and 1.000 is not significant

## Running

You will need a mysql server running locally on the default port, allowing access with user `root` without password. Or you can tweak `config/config.exs`

When ready, run:

```
mix ecto.load; mix run bench.exs
```

You can customize the benchmark by specifying a different number of unique keys and runtime:

```
mix run bench.exs 5000
```

```
mix run bench.exs 1000 10
```

## Raw results

```
Upserting 10000 unique keys for 60 seconds

Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz
Number of Available Cores: 8
Available memory: 16 GB
Elixir 1.6.6
Erlang 21.0.2
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 1 min
parallel: 1
inputs: none specified
Estimated total run time: 8.27 min


Benchmarking 1000x READ UNCOMMITTED (lowest)...
Benchmarking 1000x REPEATABLE READ (default)...
Benchmarking 100x READ UNCOMMITTED (lowest)...
Benchmarking 100x REPEATABLE READ (default)...
Benchmarking 10x  READ UNCOMMITTED (lowest)...
Benchmarking 10x  REPEATABLE READ (default)...
Benchmarking 1x   READ UNCOMMITTED (lowest)...
Benchmarking 1x   REPEATABLE READ (default)...

Name                                      ips        average  deviation         median         99th %
100x READ UNCOMMITTED (lowest)           2.82      354.33 ms     ±5.22%      354.58 ms      424.85 ms
1000x READ UNCOMMITTED (lowest)          2.79      358.74 ms    ±13.16%      350.43 ms      676.00 ms
1000x REPEATABLE READ (default)          2.74      365.55 ms     ±6.00%      363.31 ms      461.59 ms
100x REPEATABLE READ (default)           2.73      366.41 ms    ±13.22%      356.57 ms      665.06 ms
10x  READ UNCOMMITTED (lowest)           0.97     1030.94 ms    ±16.18%     1000.45 ms     2193.03 ms
10x  REPEATABLE READ (default)           0.43     2305.26 ms   ±137.71%      935.08 ms    11767.33 ms
1x   READ UNCOMMITTED (lowest)         0.0351    28451.62 ms    ±54.31%    37960.60 ms    40738.11 ms
1x   REPEATABLE READ (default)         0.0143    70161.81 ms     ±0.00%    70161.81 ms    70161.81 ms

Comparison:
100x READ UNCOMMITTED (lowest)           2.82
1000x READ UNCOMMITTED (lowest)          2.79 - 1.01x slower
1000x REPEATABLE READ (default)          2.74 - 1.03x slower
100x REPEATABLE READ (default)           2.73 - 1.03x slower
10x  READ UNCOMMITTED (lowest)           0.97 - 2.91x slower
10x  REPEATABLE READ (default)           0.43 - 6.51x slower
1x   READ UNCOMMITTED (lowest)         0.0351 - 80.30x slower
1x   REPEATABLE READ (default)         0.0143 - 198.01x slower
```
