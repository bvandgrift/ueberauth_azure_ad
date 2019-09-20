# Ueberauth Azure AD Example

If you do not have an Azure App registration set up, do so
[here](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade).
Configure a redirect URI with http://localhost:4000/auth/azure/callback.

Into your environment, throw your client id, client secret, and tenant_id:

```bash
  export AZURE_CLIENT_ID=<Application (client) ID>
  export AZURE_CLIENT_SECRET=<your client secret>
  export AZURE_TENANT_ID=<Directory (tenant) ID>
```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

To check your Azure authentication, visit:
[`localhost:4000/auth/azure`](http://localhost:4000/auth/azure) from your browser.

## Learn more about Phoenix

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
