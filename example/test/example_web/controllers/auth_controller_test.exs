defmodule ExampleWeb.AuthControllerTest do
  use ExampleWeb.ConnCase

  setup do
    Application.put_env(:ueberauth, Ueberauth.Strategy.AzureAD.OAuth,
      client_id: "TEST_CLIENT",
      client_secret: "TEST_SECRET",
      tenant_id: "TEST_TENANT")
    :ok
  end

  test "GET /auth/azure", %{conn: conn} do
    conn = get(conn, "/auth/azure")
    [redirect_url, redirect_params] = String.split(redirected_to(conn), "?")

    assert redirect_url =~ "https://login.microsoftonline.com/TEST_TENANT/oauth2/v2.0/authorize"
    assert redirect_params =~ "client_id=TEST_CLIENT&provider=azure"
  end
end
