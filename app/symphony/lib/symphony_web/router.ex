defmodule SymphonyWeb.Router do
  use SymphonyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SymphonyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug SymphonyWeb.Plugs.ApiAuth
  end

  scope "/api/v1", SymphonyWeb.Api, as: :api do
    pipe_through :api

    get "/whoami", WhoamiController, :show

    get "/resource_types", ResourceTypeController, :index
    get "/entitlements", EntitlementController, :index
    get "/grants", GrantController, :index

    resources "/musicians", MusicianController, except: [:new, :edit]
    resources "/audience_members", AudienceMemberController, except: [:new, :edit]
    resources "/sections", SectionController, except: [:new, :edit]
    resources "/ensembles", EnsembleController, except: [:new, :edit]
    resources "/venues", VenueController, except: [:new, :edit]
    resources "/instruments", InstrumentController, except: [:new, :edit]
    resources "/equipment", EquipmentController, except: [:new, :edit]
    resources "/sheet_music", SheetMusicController, except: [:new, :edit]
    resources "/performances", PerformanceController, except: [:new, :edit]
    resources "/roles", RoleController, except: [:new, :edit]
    resources "/permissions", PermissionController, except: [:new, :edit]
    resources "/applications", ApplicationController, except: [:new, :edit]
    resources "/price_tiers", PriceTierController, except: [:new, :edit]
    resources "/promo_codes", PromoCodeController, except: [:new, :edit]
    resources "/venue_sections", VenueSectionController, except: [:new, :edit]
    resources "/season_subscriptions", SeasonSubscriptionController, except: [:new, :edit]
  end

  scope "/", SymphonyWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/admin", SymphonyWeb.Admin do
    pipe_through :browser

    live_session :admin, on_mount: SymphonyWeb.AdminNav do
      live "/", DashboardLive, :index

      live "/musicians", MusicianLive.Index, :index
      live "/musicians/new", MusicianLive.Form, :new
      live "/musicians/:id", MusicianLive.Show, :show
      live "/musicians/:id/edit", MusicianLive.Form, :edit

      live "/audience_members", AudienceMemberLive.Index, :index
      live "/audience_members/new", AudienceMemberLive.Form, :new
      live "/audience_members/:id", AudienceMemberLive.Show, :show
      live "/audience_members/:id/edit", AudienceMemberLive.Form, :edit

      live "/instruments", InstrumentLive.Index, :index
    live "/instruments/new", InstrumentLive.Form, :new
    live "/instruments/:id", InstrumentLive.Show, :show
    live "/instruments/:id/edit", InstrumentLive.Form, :edit

    live "/equipment", EquipmentLive.Index, :index
    live "/equipment/new", EquipmentLive.Form, :new
    live "/equipment/:id", EquipmentLive.Show, :show
    live "/equipment/:id/edit", EquipmentLive.Form, :edit

    live "/sheet_music", SheetMusicLive.Index, :index
    live "/sheet_music/new", SheetMusicLive.Form, :new
    live "/sheet_music/:id", SheetMusicLive.Show, :show
    live "/sheet_music/:id/edit", SheetMusicLive.Form, :edit

    live "/venues", VenueLive.Index, :index
    live "/venues/new", VenueLive.Form, :new
    live "/venues/:id", VenueLive.Show, :show
    live "/venues/:id/edit", VenueLive.Form, :edit

    live "/ensembles", EnsembleLive.Index, :index
    live "/ensembles/new", EnsembleLive.Form, :new
    live "/ensembles/:id", EnsembleLive.Show, :show
    live "/ensembles/:id/edit", EnsembleLive.Form, :edit

    live "/sections", SectionLive.Index, :index
    live "/sections/new", SectionLive.Form, :new
    live "/sections/:id", SectionLive.Show, :show
    live "/sections/:id/edit", SectionLive.Form, :edit

    live "/roles", RoleLive.Index, :index
    live "/roles/new", RoleLive.Form, :new
    live "/roles/:id", RoleLive.Show, :show
    live "/roles/:id/edit", RoleLive.Form, :edit

    live "/permissions", PermissionLive.Index, :index
    live "/permissions/new", PermissionLive.Form, :new
    live "/permissions/:id", PermissionLive.Show, :show
    live "/permissions/:id/edit", PermissionLive.Form, :edit

    live "/applications", ApplicationLive.Index, :index
    live "/applications/new", ApplicationLive.Form, :new
    live "/applications/:id", ApplicationLive.Show, :show
    live "/applications/:id/edit", ApplicationLive.Form, :edit

    live "/price_tiers", PriceTierLive.Index, :index
    live "/price_tiers/new", PriceTierLive.Form, :new
    live "/price_tiers/:id", PriceTierLive.Show, :show
    live "/price_tiers/:id/edit", PriceTierLive.Form, :edit

    live "/promo_codes", PromoCodeLive.Index, :index
    live "/promo_codes/new", PromoCodeLive.Form, :new
    live "/promo_codes/:id", PromoCodeLive.Show, :show
    live "/promo_codes/:id/edit", PromoCodeLive.Form, :edit

    live "/venue_sections", VenueSectionLive.Index, :index
    live "/venue_sections/new", VenueSectionLive.Form, :new
    live "/venue_sections/:id", VenueSectionLive.Show, :show
    live "/venue_sections/:id/edit", VenueSectionLive.Form, :edit

    live "/season_subscriptions", SeasonSubscriptionLive.Index, :index
    live "/season_subscriptions/new", SeasonSubscriptionLive.Form, :new
    live "/season_subscriptions/:id", SeasonSubscriptionLive.Show, :show
    live "/season_subscriptions/:id/edit", SeasonSubscriptionLive.Form, :edit

    live "/performances", PerformanceLive.Index, :index
    live "/performances/new", PerformanceLive.Form, :new
    live "/performances/:id", PerformanceLive.Show, :show
    live "/performances/:id/edit", PerformanceLive.Form, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SymphonyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:symphony, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SymphonyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
