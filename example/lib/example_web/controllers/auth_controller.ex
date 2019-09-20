defmodule ExampleWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use ExampleWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers
  alias Example.User

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "See ya!")
    |> configure_session(drop: true)
    |> put_view(ExampleWeb.PageView)
    |> render("index.html")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "SO SORRY!")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # IO.inspect auth
    case InfoFromAuth.find_or_create(auth) do
      {:ok, user} ->
        User.find_or_create_from_auth(user)
        conn
        |> put_flash(:info, "Welcome, #{user[:name]}!")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end

