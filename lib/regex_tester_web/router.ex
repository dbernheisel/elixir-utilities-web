defmodule RegexTesterWeb.Router do
  use RegexTesterWeb, :router
  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug :basic_auth, Application.get_env(:you_meet, :basic_auth)
  end

  scope "/", RegexTesterWeb do
    pipe_through [:browser]

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RegexTesterWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  scope "/" do
    pipe_through [:browser, :auth]
    live_dashboard "/dashboard", metrics: RegexTesterWeb.Telemetry
  end
end
