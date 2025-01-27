defmodule Ueberauth.Strategy.AzureAD do
  @moduledoc """
  provides an Ueberauth strategy for authenticating against OAuth2
  endpoints in Microsoft Identity (Azure) 2.0.

  ## Setup 

  1. Setup your application at the new [Microsoft app registration portal](https://apps.dev.microsoft.com).
  1. Add `:ueberauth_azure_ad` to your list of dependencies in `mix.exs`:

      ```elixir
      def deps do
        [{:ueberauth_azure_ad, "~> 0.5"}]
      end
      ```

  1. Add the strategy to your applications:

      ```elixir
      def application do
        [applications: [:ueberauth_azure_ad]]
      end
      ```

  1. Add Microsoft to your Überauth configuration:

      ```elixir
      config :ueberauth, Ueberauth,
        providers: [
          azure: {Ueberauth.Strategy.AzureAD, []}
        ]
      ```

  1.  Update your provider configuration:

      ```elixir
      config :ueberauth, Ueberauth.Strategy.AzureAD.OAuth,
        client_id: System.get_env("AZURE_CLIENT_ID"),
        client_secret: System.get_env("AZURE_CLIENT_SECRET"),
        tenant_id: System.get_env("AZURE_TENANT_ID")
      ```

  1.  Include the Überauth plug in your controller:

      ```elixir
      defmodule MyApp.AuthController do
        use MyApp.Web, :controller
        plug Ueberauth
        ...
      end
      ```

  1.  Create the request and callback routes if you haven't already:

      ```elixir
      scope "/auth", MyApp do
        pipe_through :browser

        get "/:provider", AuthController, :request
        get "/:provider/callback", AuthController, :callback
      end
      ```

  1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

  For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

  ## Calling

  Depending on the configured url you can initial the request through:

      /auth/azure

  By default the scopes used are
  * openid
  * email
  * offline_access
  * https://graph.microsoft.com/user.read

  *Note: at least one service scope is required in order for a token to be returned by the Microsoft endpoint*

  You can configure additional scopes to be used by passing the `extra_scopes` option into the provider

  ```elixir
  config :ueberauth, Ueberauth,
    providers: [
      azure: {Ueberauth.Strategy.AzureAD, [extra_scopes: "https://graph.microsoft.com/calendars.read"]}
    ]
  ```
  """
  use Ueberauth.Strategy,
    default_scope: "https://graph.microsoft.com/user.read openid email offline_access",
    uid_field: :id

  alias OAuth2.{Response, Error}
  alias Ueberauth.Auth.{Info, Credentials, Extra}
  alias Ueberauth.Strategy.AzureAD.OAuth

  @doc """
  Handles initial request for Microsoft authentication.
  """
  def handle_request!(conn) do
    default_scopes = option(conn, :default_scope)
    extra_scopes = option(conn, :extra_scopes)

    scopes = "#{extra_scopes} #{default_scopes}"

    authorize_url =
      conn.params
      |> Map.put(:scope, scopes)
      |> Map.put(:redirect_uri, callback_url(conn))
      |> OAuth.authorize_url!()

    redirect!(conn, authorize_url)
  end

  @doc """
  Handles the callback from Microsoft.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [redirect_uri: callback_url(conn)]
    client = OAuth.get_token!([code: code], opts)
    token = client.token

    case token.access_token do
      nil ->
        err = token.other_params["error"]
        desc = token.other_params["error_description"]
        set_errors!(conn, [error(err, desc)])

      _token ->
        fetch_user(conn, client)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:ms_token, nil)
    |> put_private(:ms_user, nil)
  end

  @doc false
  def uid(conn) do
    user =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.ms_user[user]
  end

  @doc false
  def credentials(conn) do
    token = conn.private.ms_token

    %Credentials{
      expires: token.expires_at != nil,
      expires_at: token.expires_at,
      scopes: token.other_params["scope"],
      token: token.access_token,
      refresh_token: token.refresh_token,
      token_type: token.token_type
    }
  end

  @doc false
  def info(conn) do
    user = conn.private.ms_user

    %Info{
      name: user["displayName"],
      email: user["mail"] || user["userPrincipalName"],
      first_name: user["givenName"],
      last_name: user["surname"]
    }
  end

  @doc false
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.ms_token,
        user: conn.private.ms_user
      }
    }
  end

  defp fetch_user(conn, client) do
    conn = put_private(conn, :ms_token, client.token)
    path = "https://graph.microsoft.com/v1.0/me/"

    case OAuth2.Client.get(client, path) do
      {:ok, %Response{status_code: 401}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %Response{status_code: status, body: response}} when status in 200..299 ->
        put_private(conn, :ms_user, response)

      {:error, %Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp option(conn, key) do
    default = Keyword.get(default_options(), key)

    conn
    |> options
    |> Keyword.get(key, default)
  end
end
