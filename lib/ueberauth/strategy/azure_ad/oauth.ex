defmodule Ueberauth.Strategy.AzureAD.OAuth do
  @moduledoc """
  configures OAuth2 client for use with Microsoft Identity (Azure AD) 2.0.
  """
  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @defaults [
    strategy: __MODULE__,
    site: "https://graph.microsoft.com",
    request_opts: [ssl_options: [versions: [:"tlsv1.2"]]]
  ]

  @doc """
  configures the authorization and token URLs from the tenant id
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.AzureAD.OAuth)

    urls = [
      authorize_url: "https://login.microsoftonline.com/#{config[:tenant_id]}/oauth2/v2.0/authorize",
      token_url: "https://login.microsoftonline.com/#{config[:tenant_id]}/oauth2/v2.0/token",
    ]

    @defaults
    |> Keyword.merge(config)
    |> Keyword.merge(opts)
    |> Keyword.merge(urls)
    |> Client.new()
  end

  @doc """
  extract token from client, possibly throwing exception
  """
  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.get_token!(params)
  end

  @doc """
  extract token from client
  """
  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end

  # oauth2 Strategy Callbacks

  @doc """
  returns authorize url from client, given params
  """
  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  @doc """
  returns authorize url from client, given params, may throw exception
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.authorize_url!(params)
  end

end
