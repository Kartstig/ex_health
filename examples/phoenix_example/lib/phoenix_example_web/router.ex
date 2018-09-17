defmodule PhoenixExampleWeb.Router do
  require ExHealth.Plug
  use PhoenixExampleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PhoenixExampleWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    forward("/_health", HealthcheckPlug)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixExampleWeb do
  #   pipe_through :api
  # end
end
