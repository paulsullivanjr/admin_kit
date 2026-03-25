defmodule AdminKit.TestApp.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router
  import AdminKit.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/admin" do
    pipe_through :browser
    live_admin("/", AdminKit.TestApp.Admin)
  end
end
