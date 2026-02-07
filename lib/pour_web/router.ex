defmodule PourWeb.Router do
  use PourWeb, :router

  import PourWeb.UserAuth
  alias Pour.ShoppingCart

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PourWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug :fetch_current_cart
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Health check endpoint
  scope "/api", PourWeb do
    pipe_through :api
    get "/health", HealthController, :index
  end

  # Public routes (no auth required)
  scope "/", PourWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{PourWeb.UserAuth, :mount_current_scope}] do
      live "/", HomeLive.Index, :index
      live "/lot", LotLive.Index, :index
      live "/wines/:id", WineLive.MemberShow, :show
      live "/tastings", TastingLive.Index, :index
      live "/tastings/:id", TastingLive.Show, :show
      live "/blog", BlogLive.Index, :index
      live "/blog/:slug", BlogLive.Show, :show
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pour, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PourWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Pending approval page (authenticated but not necessarily approved)
  scope "/", PourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :pending_approval,
      on_mount: [{PourWeb.UserAuth, :require_authenticated}] do
      live "/pending-approval", PendingLive.Index, :index
    end
  end

  # Admin routes (authenticated + approved + admin role)
  scope "/admin", PourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin,
      on_mount: [
        {PourWeb.UserAuth, :require_authenticated},
        {PourWeb.UserAuth, :require_approved},
        {PourWeb.UserAuth, :require_admin}
      ] do
      live "/users", AdminLive.Users, :index

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

      live "/tastings", AdminLive.TastingLive.Index, :index
      live "/tastings/new", AdminLive.TastingLive.Form, :new
      live "/tastings/:id", AdminLive.TastingLive.Show, :show
      live "/tastings/:id/edit", AdminLive.TastingLive.Form, :edit

      live "/blog", AdminLive.BlogLive.Index, :index
      live "/blog/new", AdminLive.BlogLive.Form, :new
      live "/blog/:id/edit", AdminLive.BlogLive.Form, :edit
    end
  end

  # Member routes (authenticated + approved)
  scope "/", PourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :approved_member,
      on_mount: [
        {PourWeb.UserAuth, :mount_current_scope},
        {PourWeb.UserAuth, :require_approved},
        {PourWeb.UserAuth, :load_cart}
      ] do
      live "/cart", CartLive.Show, :show
      live "/orders", OrderLive.Index, :index
      live "/orders/:id", OrderLive.Show, :show
    end
  end

  # Shop routes (authenticated + approved + shop or admin role)
  scope "/shop", PourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :shop,
      on_mount: [
        {PourWeb.UserAuth, :require_authenticated},
        {PourWeb.UserAuth, :require_approved},
        {PourWeb.UserAuth, :require_shop_or_admin}
      ] do
      live "/orders", ShopLive.Dashboard, :index
      live "/orders/:id", ShopLive.OrderDetail, :show
      live "/consolidated", ShopLive.Consolidated, :index
    end
  end

  # User settings (authenticated, no approval required)
  scope "/", PourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PourWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # Auth routes (public)
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

  defp fetch_current_cart(%{assigns: %{current_scope: scope}} = conn, _opts)
       when not is_nil(scope) do
    if cart = ShoppingCart.get_cart(scope) do
      assign(conn, :cart, cart)
    else
      {:ok, new_cart} = ShoppingCart.create_cart(scope)
      assign(conn, :cart, new_cart)
    end
  end

  defp fetch_current_cart(conn, _opts), do: conn
end
