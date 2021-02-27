defmodule UtilityWeb.AuthController do
  use UtilityWeb, :controller
  require Logger

  plug Ueberauth

  def request(conn, _params) do
    # The GitHub strategy will intercept before hitting this
    url = Ueberauth.Strategy.Helpers.callback_url(conn)
    Logger.debug(url)
    render(conn, "request.html", callback_url: url)
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UtilityWeb.UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome #{user.name}")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "/")
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out")
    |> clear_session()
    |> redirect(to: "/")
  end
end
