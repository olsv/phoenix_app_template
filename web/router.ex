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

  # pipeline :require_login do
  #   plug Guardian.Plug.EnsureAuthenticated, handler: PhoenixAppTemplate.GuardianErrorHandler
  # end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixAppTemplate do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    resources "/user", UserController, except: [:delete, :index, :show]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/", PageController, :index
  end

  # scope "/", PhoenixAppTemplate do
  #   pipe_through [:browser, :browser_session, :require_login]
  # end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixAppTemplate do
  #   pipe_through :api
  # end
end
