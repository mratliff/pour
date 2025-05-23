defmodule PourWeb.Router do
  use PourWeb, :router

  import PourWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PourWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PourWeb do
    pipe_through :browser

    live "/wines", WineLive.Index, :index
    live "/wines/new", WineLive.Form, :new
    live "/wines/:id", WineLive.Show, :show
    live "/wines/:id/edit", WineLive.Form, :edit

    live "/countries", CountryLive.Index, :index
    live "/countries/new", CountryLive.Form, :new
    live "/countries/:id", CountryLive.Show, :show
    live "/countries/:id/edit", CountryLive.Form, :edit

    live "/regions", RegionLive.Index, :index
    live "/regions/new", RegionLive.Form, :new
    live "/regions/:id", RegionLive.Show, :show
    live "/regions/:id/edit", RegionLive.Form, :edit

    live "/subregions", SubregionLive.Index, :index
    live "/subregions/new", SubregionLive.Form, :new
    live "/subregions/:id", SubregionLive.Show, :show
    live "/subregions/:id/edit", SubregionLive.Form, :edit

    live "/varietals", VarietalLive.Index, :index
    live "/varietals/new", VarietalLive.Form, :new
    live "/varietals/:id", VarietalLive.Show, :show
    live "/varietals/:id/edit", VarietalLive.Form, :edit

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", PourWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pour, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PourWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :authenticated,
      on_mount: [{PourWeb.UserAuth, :mount_current_scope}, {PourWeb.UserAuth, :load_cart}] do
      live "/lot", LotLive.Index, :index
      live "/cart", CartLive.Show, :show
    end
  end

  scope "/", PourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PourWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", PourWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{PourWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  # defp fetch_current_cart(%{assigns: %{current_scope: scope}} = conn, _opts)
  #      when not is_nil(scope) do
  #   if cart = ShoppingCart.get_cart(scope) do
  #     assign(conn, :cart, cart)
  #   else
  #     {:ok, new_cart} = ShoppingCart.create_cart(scope)
  #     assign(conn, :cart, new_cart)
  #   end
  # end

  # defp fetch_current_cart(conn, _opts), do: conn
end
