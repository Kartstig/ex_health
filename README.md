# ExHealth ![ExHealth](logo.png)
> A health check utility for any OTP application

[![Build Status](https://circleci.com/gh/MatchedPattern/ex_health/tree/master.svg?style=svg&circle-token=8ed28fee90111e2a034b0d71e0fcf8ae18bba641)](https://circleci.com/gh/MatchedPattern/ex_health/tree/master) [![codecov](https://codecov.io/gh/MatchedPattern/ex_health/branch/master/graph/badge.svg)](https://codecov.io/gh/MatchedPattern/ex_health)

ExHealth runs a supervised GenServer that performs routine health checks which
are configurable to your application. Check out [ExHealth.Plug](lib/ex_health/plug.ex)
for integrating the result into a web endpoint which yields a JSON response like:

```javascript
{
   last_check:"2018-09-18T06:43:53.773719Z",
   result:{
      check_results:[
         [
            "Database",
            true
         ],
         [
            "PhoenixExampleWeb_Endpoint",
            true
         ]
      ],
      msg:"healthy"
   }
}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_health` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_health, "~> 0.1.0"}
  ]
end
```

Ensure ex_health is started alongside your application by adding this to your `mix.exs`

```elixir
def application do
  [applications: [:ex_health]]
end
```

## Getting Started

Configuration for ExHealth must be present the Application environment. This
can be done by updating the `:ex_health` values in your `config/config.exs`:
```elixir
config :ex_health,
  module: MyApplication.HealthChecks,
  interval_ms: 1000
```

Then you must define a module `MyApplication.HealthChecks` with some checks:
```elixir
defmodule MyApplication.HealthChecks do
  process_check(MyApplication.CacheServer)

  test "Redis" do
    MyRedis.ping() # This should return :ok | {:error, "Message"}
  end
end
```

## Online Documentation

Please see the documentation for ExHealth at [https://hexdocs.pm/ex_health](https://hexdocs.pm/ex_health)

## Offline Documentation

You can generate documentation by running the following:
```bash
$ mix docs
```

You can find examples in [examples/](examples/)

## Contributing

Pull requests are welcome. The best way to get started is to check out [CONTRIBUTING](CONTRIBUTING.md).

Once you have the repo cloned, just run
```bash
$ mix deps.get
```

and then you can start ExHealth with CLI:
```bash
$ iex -S mix
```

## License

See [LICENSE](LICENSE) for more information.


_by Herman Singh of Matched Pattern_