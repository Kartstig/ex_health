defmodule PhoenixExampleWeb.PageController do
  use PhoenixExampleWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
