defmodule ExampleWeb.SecretController do
  use ExampleWeb, :controller

  def index(conn, _params) do
    current_user = get_session(conn, :current_user)
    if current_user do
      conn |> render("index.html", current_user: current_user)
    else
      conn
      |> put_status(:not_found)
      |> put_view(ExampleWeb.ErrorView)
      |> render("404.html")
    end
  end
end
