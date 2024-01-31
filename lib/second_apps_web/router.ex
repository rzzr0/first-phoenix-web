defmodule SecondAppsWeb.Router do
  use SecondAppsWeb, :router

  import SecondAppsWeb.DeveloperAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SecondAppsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_developer
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SecondAppsWeb do
    pipe_through :browser

    get "/", PageController, :home

  end

  # Other scopes may use custom stacks.
  # scope "/api", SecondAppsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:second_apps, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SecondAppsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SecondAppsWeb do
    pipe_through [:browser, :redirect_if_developer_is_authenticated]

    live_session :redirect_if_developer_is_authenticated,
      on_mount: [{SecondAppsWeb.DeveloperAuth, :redirect_if_developer_is_authenticated}] do
      live "/developers/register", DeveloperRegistrationLive, :new
      live "/developers/log_in", DeveloperLoginLive, :new
      live "/developers/reset_password", DeveloperForgotPasswordLive, :new
      live "/developers/reset_password/:token", DeveloperResetPasswordLive, :edit
    end

    post "/developers/log_in", DeveloperSessionController, :create
  end

  scope "/", SecondAppsWeb do
    pipe_through [:browser, :require_authenticated_developer]

    live_session :require_authenticated_developer,
      on_mount: [{SecondAppsWeb.DeveloperAuth, :ensure_authenticated}] do
      live "/developers/settings", DeveloperSettingsLive, :edit
      live "/developers/settings/confirm_email/:token", DeveloperSettingsLive, :confirm_email
      resources "/hobbies", HobbieController
      resources "/pendidikans", PendidikanController
      resources "/org", OrganisaionController
      resources "/kejuaraans", KejuaraanController
    end
  end

  scope "/", SecondAppsWeb do
    pipe_through [:browser]

    delete "/developers/log_out", DeveloperSessionController, :delete

    live_session :current_developer,
      on_mount: [{SecondAppsWeb.DeveloperAuth, :mount_current_developer}] do
      live "/developers/confirm/:token", DeveloperConfirmationLive, :edit
      live "/developers/confirm", DeveloperConfirmationInstructionsLive, :new
    end
  end
end
