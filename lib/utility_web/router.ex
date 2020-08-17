defmodule UtilityWeb.Router do
  use UtilityWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {UtilityWeb.LayoutView, :root}
  end

  pipeline :crawlers do
    plug :accepts, ["xml", "json", "webmanifest"]
  end

  pipeline :auth do
    plug :check_auth
  end

  scope "/", UtilityWeb do
    pipe_through [:browser]

    get "/", PageController, :show
    get "/about", PageController, :about
    live "/regex", RegexLive
    live "/regex/:id", RegexLive
  end

  scope "/", UtilityWeb do
    pipe_through [:crawlers]

    get "/site.webmanifest", PageController, :site_manifest
    get "/browserconfig.xml", PageController, :browserconfig
  end

  # Other scopes may use custom stacks.
  # scope "/api", UtilityWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  scope "/admin" do
    pipe_through [:browser, :auth]
    live_dashboard "/dashboard", metrics: UtilityWeb.Telemetry
  end

  def check_auth(conn, _opts) do
    with {user, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
         true <- user == System.get_env("AUTH_USER"),
         true <- pass == System.get_env("AUTH_PASS") do
      conn
    else
      _ ->
        conn
        |> Plug.BasicAuth.request_basic_auth()
        |> halt()
    end
  end
end
