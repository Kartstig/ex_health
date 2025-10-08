# ExHealth ![ExHealth](./assets/logo.png)

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/Kartstig/ex_health/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/Kartstig/ex_health/tree/master)
[![codecov](https://codecov.io/gh/Kartstig/ex_health/branch/master/graph/badge.svg)](https://codecov.io/gh/Kartstig/ex_health)
[![Module Version](https://img.shields.io/hexpm/v/ex_health.svg)](https://hex.pm/packages/ex_health)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_health/)
[![Total Download](https://img.shields.io/hexpm/dt/ex_health.svg)](https://hex.pm/packages/ex_health)
[![License](https://img.shields.io/hexpm/l/ex_health.svg)](https://github.com/Kartstig/ex_health/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/Kartstig/ex_health.svg)](https://github.com/Kartstig/ex_health/commits/master)

> A health check utility for any OTP application

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
            "ok"
         ],
         [
            "PhoenixExampleWeb_Endpoint",
            "ok"
         ]
      ],
      msg:"healthy"
   }
}
```

## Installation

Add `:ex_health` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_health, "~> 0.4.0"}
  ]
end
```

Ensure `:ex_health` is started alongside your application by adding this to
your `mix.exs`

```elixir
def application do
  [
    applications: [:ex_health]
  ]
end
```

## Getting Started

Configuration for ExHealth must be present the Application environment. This
can be done by updating the `:ex_health` values in your `config/config.exs`:

```elixir
config :ex_health,
  module: MyApplication.HealthChecks,
  interval_ms: 1000, # Interval between checks in milliseconds
  http_err_code: true # Enable http error code (503) on unhealthy status
```

Then you must define a module `MyApplication.HealthChecks` with some checks:

```elixir
defmodule MyApplication.HealthChecks do
  import ExHealth
  process_check(MyApplication.CacheServer)

  health_check "Redis" do
    MyRedis.ping() # This should return :ok | {:error, "Message"}
  end
end
```

## Integrating with Phoenix

To integrate with [Phoenix](https://hexdocs.pm/phoenix/Phoenix.html)
or any other web framework, you can take advantage of `ExHealth.Plug`
which handles serving a JSON response for you.

See `ExHealth.Plug` for instructions.

## Contributing

Pull requests are welcome. The best way to get started is to check out
[CONTRIBUTING](CONTRIBUTING.md).

Once you have the repo cloned, just run:

```bash
$ mix deps.get
```

and then you can start ExHealth with CLI:

```bash
$ iex -S mix
```

## Sponsorship

Put your logo here! [Become a sponsor](https://github.com/sponsors/Kartstig) and support this project!

## Copyright and License

Copyright (c) 2018 Herman Singh.

This software is licensed under [the MIT license](./LICENSE.md).
