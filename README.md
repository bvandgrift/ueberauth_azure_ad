# Überauth Strategy for Azure AD v2.0, Single Tenant OAuth2

A simple implementation of OAuth that includes the `tenant_id` in the 
OAuth2 endpoint, facilitating the Microsoft identity platform version 2.

Originally forked in a hurry from [swelhan/ueberauth_microsoft](http://github.com/swelham/ueberauth_microsoft),
with much gratitude.

## Installation

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

## License

Please see [LICENSE](https://github.com/bvandgrift/ueberauth_azure_ad/blob/master/LICENSE) for licensing details.
