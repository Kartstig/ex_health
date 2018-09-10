defmodule PhoenixAppWeb.Router do
  use PhoenixAppWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", PhoenixAppWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end
end
