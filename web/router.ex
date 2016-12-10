defmodule PhoenixAppTemplate.Router do
  use PhoenixAppTemplate.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :require_authentication do
    plug Guardian.Plug.EnsureAuthenticated, handler: PhoenixAppTemplate.GuardianErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixAppTemplate do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    resources "/user", UserController, only: [:new, :create]
    resources "/session", SessionController, only: [:new, :create, :delete], singleton: true
    get "/", PageController, :index, as: :root
  end

  scope "/", PhoenixAppTemplate do
    # all requests within this scope require authentication
    pipe_through [:browser, :browser_session, :require_authentication]

    # singleton: true removes id from path
    resources "/user", UserController, only: [:show, :edit, :update], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixAppTemplate do
  #   pipe_through :api
  # end
end
