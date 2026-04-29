# Script for populating the database. Run with:
#
#     mix run priv/repo/seeds.exs
#
# Idempotent: clears existing rows in dependency order, then re-inserts a
# small but representative dataset that exercises every layer of the schema
# — staff and audience identities, sections/ensembles, inventory,
# RBAC, a venue with a seat map, a performance with pricing, a comp ticket,
# a season subscription, request schemas, and one audit event.

alias Symphony.Repo

alias Symphony.Identity.{Musician, MusicianEmail, AudienceMember, AudienceEmail}
alias Symphony.Orchestra.{Section, SectionMembership, Ensemble, EnsembleMembership, Venue}
alias Symphony.Inventory.{Instrument, Equipment, SheetMusic, SheetMusicPart}
alias Symphony.Rbac.{Role, Permission, RolePermission, RoleAssignment,
                     RoleScopeBinding, ResourceOwner, Application,
                     ApplicationAssignment}
alias Symphony.Checkouts.{InstrumentCheckout, SheetMusicAccess}
alias Symphony.Scheduling.{Performance, PerformanceSetlistEntry}
alias Symphony.Ticketing.{VenueSection, Seat, PriceTier, PerformancePricing,
                           PerformanceOnSaleState, SeasonSubscription,
                           SeasonSubscriptionPerformance, SubscriptionHolding,
                           Order, OrderItem, Payment, Ticket}
alias Symphony.Secrets.{ApiKey, DoorBadge}
alias Symphony.Security.Finding
alias Symphony.Requests.{Schema, CustomFieldDef}
alias Symphony.Audit.Event
alias Symphony.Actions.Invocation

now = DateTime.utc_now() |> DateTime.truncate(:second)

# ---- 1. Truncate in reverse dependency order ----

for schema <- [
      Invocation, Event, Ticket, OrderItem, Payment, Order,
      SubscriptionHolding, SeasonSubscriptionPerformance, SeasonSubscription,
      PerformancePricing, PerformanceOnSaleState, Seat, VenueSection,
      PriceTier, PerformanceSetlistEntry, Performance,
      SheetMusicAccess, InstrumentCheckout,
      ApplicationAssignment, Application, ResourceOwner, RoleScopeBinding,
      RoleAssignment, RolePermission, Permission, Role,
      Finding, DoorBadge, ApiKey,
      CustomFieldDef, Schema,
      SheetMusicPart, SheetMusic, Equipment, Instrument,
      EnsembleMembership, Ensemble, SectionMembership, Section, Venue,
      AudienceEmail, AudienceMember, MusicianEmail, Musician
    ] do
  Repo.delete_all(schema)
end

# ---- 2. Musicians (staff) ----

%{id: marin_id} =
  Repo.insert!(%Musician{
    login: "marin.alsop",
    primary_email: "marin.alsop@symphony.test",
    given_name: "Marin",
    family_name: "Alsop",
    account_type: :human,
    status: :enabled,
    employee_id: "EMP-0001",
    mfa_enabled: true,
    sso_enabled: true
  })

%{id: yo_yo_id} =
  Repo.insert!(%Musician{
    login: "yoyo.ma",
    primary_email: "yoyo.ma@symphony.test",
    given_name: "Yo-Yo",
    family_name: "Ma",
    account_type: :human,
    status: :enabled,
    employee_id: "EMP-0002",
    mfa_enabled: true,
    sso_enabled: true
  })

%{id: hilary_id} =
  Repo.insert!(%Musician{
    login: "hilary.hahn",
    primary_email: "hilary.hahn@symphony.test",
    given_name: "Hilary",
    family_name: "Hahn",
    account_type: :human,
    status: :enabled,
    employee_id: "EMP-0003"
  })

%{id: librarian_id} =
  Repo.insert!(%Musician{
    login: "alex.librarian",
    primary_email: "alex.librarian@symphony.test",
    given_name: "Alex",
    family_name: "Reed",
    account_type: :human,
    status: :enabled,
    employee_id: "EMP-0042"
  })

%{id: stage_mgr_id} =
  Repo.insert!(%Musician{
    login: "sam.stage",
    primary_email: "sam.stage@symphony.test",
    given_name: "Sam",
    family_name: "Park",
    account_type: :human,
    status: :enabled,
    employee_id: "EMP-0099"
  })

%{id: box_office_id} =
  Repo.insert!(%Musician{
    login: "robin.boxoffice",
    primary_email: "robin@symphony.test",
    given_name: "Robin",
    family_name: "Cho",
    account_type: :human,
    status: :enabled,
    employee_id: "EMP-0210"
  })

%{id: sync_bot_id} =
  Repo.insert!(%Musician{
    login: "baton-connector",
    primary_email: "baton@symphony.test",
    account_type: :service,
    status: :enabled,
    employee_id: "SVC-001"
  })

# Disabled (former employee) for status-coverage.
Repo.insert!(%Musician{
  login: "ghost.player",
  primary_email: "ghost@symphony.test",
  given_name: "Pat",
  family_name: "Ghost",
  account_type: :human,
  status: :disabled,
  status_details: "left ensemble 2025-09-15"
})

for {musician_id, addr, primary?} <- [
      {marin_id, "marin.alsop@symphony.test", true},
      {marin_id, "conductor@personal.test", false},
      {yo_yo_id, "yoyo.ma@symphony.test", true},
      {hilary_id, "hilary.hahn@symphony.test", true},
      {librarian_id, "alex.librarian@symphony.test", true},
      {stage_mgr_id, "sam.stage@symphony.test", true},
      {box_office_id, "robin@symphony.test", true}
    ] do
  Repo.insert!(%MusicianEmail{
    musician_id: musician_id,
    address: addr,
    is_primary: primary?
  })
end

# ---- 3. Audience members ----

%{id: patron_a_id} =
  Repo.insert!(%AudienceMember{
    login: "rivera.fan",
    primary_email: "rivera@example.test",
    given_name: "Diego",
    family_name: "Rivera",
    marketing_opt_in: true,
    loyalty_tier: :gold,
    loyalty_points: 4200
  })

%{id: patron_b_id} =
  Repo.insert!(%AudienceMember{
    login: "okeefe.fan",
    primary_email: "okeefe@example.test",
    given_name: "Georgia",
    family_name: "OKeefe",
    marketing_opt_in: false,
    loyalty_tier: :bronze,
    loyalty_points: 250
  })

Repo.insert!(%AudienceEmail{
  audience_member_id: patron_a_id,
  address: "rivera@example.test",
  is_primary: true
})

Repo.insert!(%AudienceEmail{
  audience_member_id: patron_b_id,
  address: "okeefe@example.test",
  is_primary: true
})

# ---- 4. Sections (with parent → child nesting) ----

%{id: strings_id} = Repo.insert!(%Section{name: "Strings", description: "All string instruments"})
%{id: woodwinds_id} = Repo.insert!(%Section{name: "Woodwinds"})
%{id: brass_id} = Repo.insert!(%Section{name: "Brass"})
%{id: percussion_id} = Repo.insert!(%Section{name: "Percussion"})

%{id: violins_1_id} =
  Repo.insert!(%Section{name: "1st Violins", parent_section_id: strings_id})

Repo.insert!(%Section{name: "2nd Violins", parent_section_id: strings_id})
Repo.insert!(%Section{name: "Violas", parent_section_id: strings_id})
%{id: cellos_id} = Repo.insert!(%Section{name: "Cellos", parent_section_id: strings_id})
Repo.insert!(%Section{name: "Double Basses", parent_section_id: strings_id})

# ---- 5. Section memberships ----

Repo.insert!(%SectionMembership{
  section_id: violins_1_id,
  musician_id: hilary_id,
  is_principal: true,
  joined_at: now
})

Repo.insert!(%SectionMembership{
  section_id: cellos_id,
  musician_id: yo_yo_id,
  is_principal: true,
  joined_at: now
})

# ---- 6. Ensembles ----

%{id: full_orchestra_id} =
  Repo.insert!(%Ensemble{
    name: "Symphony Full Orchestra",
    kind: "full",
    description: "Primary touring ensemble"
  })

Repo.insert!(%Ensemble{name: "Symphony Chamber Players", kind: "chamber"})

Repo.insert!(%EnsembleMembership{
  ensemble_id: full_orchestra_id,
  musician_id: hilary_id,
  chair_position: 1
})

Repo.insert!(%EnsembleMembership{
  ensemble_id: full_orchestra_id,
  musician_id: yo_yo_id,
  chair_position: 5
})

# ---- 7. Venues ----

%{id: hall_id} =
  Repo.insert!(%Venue{
    name: "Heinz Hall",
    address: "600 Penn Ave, Pittsburgh, PA"
  })

Repo.insert!(%Venue{name: "Rehearsal Studio A", address: "1 Backstage Way"})

# ---- 8. Inventory: instruments ----

%{id: stradivarius_id} =
  Repo.insert!(%Instrument{
    asset_tag: "VLN-0001",
    family: "strings",
    kind: "violin",
    manufacturer: "Stradivari",
    model: "1715 Cremonese",
    serial_number: "STR-1715",
    acquisition_value_cents: 1_500_000_000,
    condition: :excellent,
    status: :checked_out,
    storage_venue_id: hall_id
  })

%{id: cello_id} =
  Repo.insert!(%Instrument{
    asset_tag: "VLC-0001",
    family: "strings",
    kind: "cello",
    manufacturer: "Davidov",
    model: "1712",
    condition: :excellent,
    status: :checked_out,
    storage_venue_id: hall_id
  })

Repo.insert!(%Instrument{
  asset_tag: "TPT-0007",
  family: "brass",
  kind: "trumpet",
  manufacturer: "Bach",
  condition: :good,
  status: :available,
  storage_venue_id: hall_id
})

Repo.insert!(%Instrument{
  asset_tag: "TIM-0001",
  family: "percussion",
  kind: "timpani_set",
  condition: :good,
  status: :available,
  storage_venue_id: hall_id
})

# ---- 9. Inventory: equipment ----

Repo.insert!(%Equipment{
  asset_tag: "MIC-0001",
  category: "microphone",
  description: "Neumann KM 184 stereo pair",
  storage_venue_id: hall_id
})

Repo.insert!(%Equipment{
  asset_tag: "STD-0001",
  category: "stand",
  description: "Manhasset music stand",
  storage_venue_id: hall_id
})

# ---- 10. Sheet music ----

%{id: dvorak_id} =
  Repo.insert!(%SheetMusic{
    title: "Cello Concerto in B minor",
    composer: "Antonín Dvořák",
    catalog_number: "DVK-OP104",
    difficulty: "grade_6",
    duration_seconds: 2400,
    copyright_status: :public_domain,
    storage_uri: "library://dvorak/op104/full-score.pdf"
  })

%{id: brahms_id} =
  Repo.insert!(%SheetMusic{
    title: "Symphony No. 4 in E minor",
    composer: "Johannes Brahms",
    catalog_number: "BRA-OP98",
    difficulty: "grade_6",
    duration_seconds: 2520,
    copyright_status: :public_domain,
    storage_uri: "library://brahms/op98/full-score.pdf"
  })

Repo.insert!(%SheetMusic{
  title: "Premiere: Untitled (commissioned)",
  composer: "C. Reicha",
  difficulty: "grade_5",
  duration_seconds: 600,
  copyright_status: :restricted,
  storage_uri: "library://commissions/2026/reicha-1/full-score.pdf"
})

Repo.insert!(%SheetMusicPart{
  sheet_music_id: dvorak_id,
  instrument_kind: "cello_solo",
  storage_uri: "library://dvorak/op104/cello-solo.pdf"
})

Repo.insert!(%SheetMusicPart{
  sheet_music_id: brahms_id,
  instrument_kind: "violin_1",
  storage_uri: "library://brahms/op98/violin-1.pdf"
})

# ---- 11. RBAC: roles + permissions catalog ----

permission_specs = [
  {"performance:manage", "performance"},
  {"performance:manage_on_sale", "performance"},
  {"performance:attend", "performance"},
  {"performance:cancel", "performance"},
  {"setlist:edit", "performance"},
  {"musician:read_all", "musician"},
  {"musician:create", "musician"},
  {"musician:disable", "musician"},
  {"audience:read_all", "audience_member"},
  {"audience:export", "audience_member"},
  {"audience:create", "audience_member"},
  {"section:manage_members", "section"},
  {"instrument:checkout", "instrument"},
  {"instrument:checkout_for_section", "instrument"},
  {"instrument:create", "instrument"},
  {"instrument:edit", "instrument"},
  {"instrument:retire", "instrument"},
  {"instrument:read_all", "instrument"},
  {"equipment:checkout", "equipment"},
  {"equipment:create", "equipment"},
  {"equipment:edit", "equipment"},
  {"sheet_music:read", "sheet_music"},
  {"sheet_music:read_all", "sheet_music"},
  {"sheet_music:create", "sheet_music"},
  {"sheet_music:edit", "sheet_music"},
  {"sheet_music:grant_access", "sheet_music"},
  {"venue:book", "venue"},
  {"order:create", "order"},
  {"order:override", "order"},
  {"order:read_own", "order"},
  {"ticket:scan", "ticket"},
  {"ticket:reserve", "ticket"},
  {"ticket:refund", "ticket"},
  {"ticket:comp", "ticket"},
  {"pricing:edit", "performance_pricing"},
  {"promo_code:manage", "promo_code"},
  {"subscription:read", "season_subscription"},
  {"subscription:edit", "season_subscription"},
  {"seat:reserve_priority", "seat"},
  {"request:create", "request"},
  {"request:approve", "request"}
]

permission_id_by_slug =
  for {slug, kind} <- permission_specs, into: %{} do
    %{id: pid} =
      Repo.insert!(%Permission{slug: slug, resource_kind: kind, description: slug})

    {slug, pid}
  end

role_specs = [
  {"music_director", "Music Director", :all},
  {"conductor", "Conductor",
   ~w(performance:manage setlist:edit sheet_music:read_all musician:read_all)},
  {"section_leader", "Section Leader",
   ~w(section:manage_members instrument:checkout_for_section request:approve
      musician:read_all)},
  {"principal_player", "Principal Player",
   ~w(instrument:checkout sheet_music:read equipment:checkout request:create)},
  {"musician", "Musician",
   ~w(instrument:checkout equipment:checkout sheet_music:read request:create)},
  {"librarian", "Librarian",
   ~w(sheet_music:create sheet_music:edit sheet_music:grant_access
      sheet_music:read_all instrument:read_all)},
  {"stage_manager", "Stage Manager",
   ~w(equipment:create equipment:edit venue:book)},
  {"box_office_manager", "Box Office Manager",
   ~w(performance:manage_on_sale pricing:edit ticket:refund ticket:comp
      order:override audience:read_all promo_code:manage)},
  {"box_office_agent", "Box Office Agent",
   ~w(order:create ticket:scan ticket:reserve audience:create audience:read_all)},
  {"usher", "Usher", ~w(ticket:scan)},
  {"subscriber", "Season Subscriber",
   ~w(subscription:read seat:reserve_priority order:read_own performance:attend)},
  {"patron", "Patron", ~w(performance:attend order:read_own)},
  {"comp_recipient", "Comp Recipient", ~w(performance:attend)}
]

role_id_by_slug =
  for {slug, display, perms} <- role_specs, into: %{} do
    %{id: rid} = Repo.insert!(%Role{slug: slug, display_name: display})

    perm_slugs =
      case perms do
        :all -> Map.keys(permission_id_by_slug)
        list -> list
      end

    for ps <- perm_slugs do
      Repo.insert!(%RolePermission{
        role_id: rid,
        permission_id: Map.fetch!(permission_id_by_slug, ps)
      })
    end

    {slug, rid}
  end

# ---- 12. Role assignments ----

assignments = [
  {marin_id, "music_director"},
  {marin_id, "conductor"},
  {hilary_id, "principal_player"},
  {hilary_id, "musician"},
  {yo_yo_id, "principal_player"},
  {yo_yo_id, "musician"},
  {librarian_id, "librarian"},
  {stage_mgr_id, "stage_manager"},
  {box_office_id, "box_office_agent"}
]

for {musician_id, role_slug} <- assignments do
  Repo.insert!(%RoleAssignment{
    role_id: Map.fetch!(role_id_by_slug, role_slug),
    musician_id: musician_id,
    granted_at: now,
    granted_by_id: marin_id
  })
end

Repo.insert!(%RoleAssignment{
  role_id: Map.fetch!(role_id_by_slug, "subscriber"),
  audience_member_id: patron_a_id,
  granted_at: now
})

Repo.insert!(%RoleAssignment{
  role_id: Map.fetch!(role_id_by_slug, "patron"),
  audience_member_id: patron_b_id,
  granted_at: now
})

# ---- 13. Role scope binding (section_leader of strings) ----

Repo.insert!(%RoleScopeBinding{
  role_id: Map.fetch!(role_id_by_slug, "section_leader"),
  scope_resource_kind: "section",
  scope_resource_id: strings_id
})

# ---- 14. Resource ownership ----

Repo.insert!(%ResourceOwner{
  resource_kind: "sheet_music",
  resource_id: dvorak_id,
  musician_id: librarian_id,
  ownership_type: :curator
})

Repo.insert!(%ResourceOwner{
  resource_kind: "instrument",
  resource_id: stradivarius_id,
  musician_id: hilary_id,
  ownership_type: :primary
})

# ---- 15. Applications + assignments ----

%{id: scheduler_app_id} =
  Repo.insert!(%Application{
    slug: "symphony-scheduler",
    display_name: "Symphony Scheduler",
    help_url: "https://help.example.test/scheduler",
    flags: ["saml"]
  })

%{id: library_app_id} =
  Repo.insert!(%Application{
    slug: "music-library",
    display_name: "Music Library Portal",
    flags: ["oidc"]
  })

for app_id <- [scheduler_app_id, library_app_id],
    musician_id <- [marin_id, hilary_id, yo_yo_id, librarian_id] do
  Repo.insert!(%ApplicationAssignment{
    application_id: app_id,
    musician_id: musician_id,
    granted_at: now
  })
end

# ---- 16. Open checkouts (currently held items) ----

Repo.insert!(%InstrumentCheckout{
  instrument_id: stradivarius_id,
  musician_id: hilary_id,
  checked_out_at: now,
  due_at: DateTime.add(now, 90 * 24 * 3600, :second),
  condition_out: "excellent"
})

Repo.insert!(%InstrumentCheckout{
  instrument_id: cello_id,
  musician_id: yo_yo_id,
  checked_out_at: now,
  due_at: DateTime.add(now, 90 * 24 * 3600, :second),
  condition_out: "excellent"
})

# Restricted-score access grant.
Repo.insert!(%SheetMusicAccess{
  sheet_music_id: dvorak_id,
  musician_id: yo_yo_id,
  granted_at: now,
  reason: "soloist"
})

# ---- 17. A performance with setlist ----

opening_at = DateTime.add(now, 30 * 24 * 3600, :second)

%{id: opening_perf_id} =
  Repo.insert!(%Performance{
    ensemble_id: full_orchestra_id,
    venue_id: hall_id,
    scheduled_at: opening_at,
    kind: :concert
  })

Repo.insert!(%PerformanceSetlistEntry{
  performance_id: opening_perf_id,
  sheet_music_id: dvorak_id,
  ordering: 1
})

Repo.insert!(%PerformanceSetlistEntry{
  performance_id: opening_perf_id,
  sheet_music_id: brahms_id,
  ordering: 2
})

Repo.insert!(%PerformanceOnSaleState{
  performance_id: opening_perf_id,
  status: :on_sale,
  announced_at: now,
  on_sale_at: now
})

# ---- 18. Seat map for Heinz Hall ----

%{id: orchestra_section_id} =
  Repo.insert!(%VenueSection{
    venue_id: hall_id,
    name: "Orchestra",
    display_order: 1,
    capacity: 20
  })

%{id: mezz_section_id} =
  Repo.insert!(%VenueSection{
    venue_id: hall_id,
    name: "Mezzanine",
    display_order: 2,
    capacity: 10
  })

orchestra_seats =
  for row <- ["A", "B"], num <- 1..10 do
    Repo.insert!(%Seat{
      venue_section_id: orchestra_section_id,
      row_label: row,
      seat_number: Integer.to_string(num),
      accessibility:
        if(row == "A" and num == 1, do: :wheelchair, else: :standard)
    })
  end

mezz_seats =
  for num <- 1..10 do
    Repo.insert!(%Seat{
      venue_section_id: mezz_section_id,
      row_label: "MZ",
      seat_number: Integer.to_string(num),
      accessibility: :standard
    })
  end

# ---- 19. Price tiers + per-(performance, section, tier) pricing ----

%{id: premium_id} =
  Repo.insert!(%PriceTier{slug: "premium", display_name: "Premium"})

%{id: standard_id} =
  Repo.insert!(%PriceTier{slug: "standard", display_name: "Standard"})

%{id: student_id} =
  Repo.insert!(%PriceTier{slug: "student", display_name: "Student Rush"})

%{id: comp_id} =
  Repo.insert!(%PriceTier{slug: "comp", display_name: "Comp", is_comp: true})

for {section_id, tier_id, cents} <- [
      {orchestra_section_id, premium_id, 18_000},
      {orchestra_section_id, standard_id, 9_500},
      {orchestra_section_id, student_id, 2_500},
      {orchestra_section_id, comp_id, 0},
      {mezz_section_id, premium_id, 12_000},
      {mezz_section_id, standard_id, 6_000},
      {mezz_section_id, student_id, 1_500},
      {mezz_section_id, comp_id, 0}
    ] do
  Repo.insert!(%PerformancePricing{
    performance_id: opening_perf_id,
    venue_section_id: section_id,
    price_tier_id: tier_id,
    price_cents: cents,
    on_sale_at: now,
    off_sale_at: opening_at
  })
end

# ---- 20. A real ticket sale ----

%{id: order_id} =
  Repo.insert!(%Order{
    order_number: "ORD-2026-00001",
    audience_member_id: patron_a_id,
    status: :paid,
    subtotal_cents: 18_000,
    fees_cents: 500,
    tax_cents: 1_480,
    total_cents: 19_980,
    channel: :web,
    placed_at: now
  })

%{id: order_item_id} =
  Repo.insert!(%OrderItem{
    order_id: order_id,
    kind: :ticket,
    performance_id: opening_perf_id,
    description: "Opening Night — Premium Orchestra A1",
    unit_price_cents: 18_000,
    quantity: 1,
    line_total_cents: 18_000
  })

Repo.insert!(%Payment{
  order_id: order_id,
  provider: "stripe",
  provider_charge_id: "ch_demo_001",
  amount_cents: 19_980,
  status: :captured,
  last4: "4242",
  captured_at: now
})

[a1_seat | _] = orchestra_seats

Repo.insert!(%Ticket{
  performance_id: opening_perf_id,
  seat_id: a1_seat.id,
  price_tier_id: premium_id,
  price_cents_paid: 18_000,
  audience_member_id: patron_a_id,
  order_item_id: order_item_id,
  status: :sold,
  barcode: "BC-OPENING-A1-#{:rand.uniform(999_999)}",
  issued_at: now
})

# ---- 21. A comped ticket (connector-managed grant of `attend`) ----

[mz1 | _] = mezz_seats

Repo.insert!(%Ticket{
  performance_id: opening_perf_id,
  seat_id: mz1.id,
  price_tier_id: comp_id,
  price_cents_paid: 0,
  audience_member_id: patron_b_id,
  status: :comped,
  barcode: "BC-COMP-MZ1-#{:rand.uniform(999_999)}",
  issued_at: now
})

# ---- 22. Season subscription bundle ----

%{id: subscription_id} =
  Repo.insert!(%SeasonSubscription{
    slug: "2026_spring_classics",
    display_name: "2026 Spring Classics Series",
    description: "Six concerts, one premium seat, no ticketing fees.",
    ensemble_id: full_orchestra_id,
    total_seats_per_holder: 1,
    base_price_cents: 80_000,
    on_sale_at: now,
    active: true
  })

Repo.insert!(%SeasonSubscriptionPerformance{
  subscription_id: subscription_id,
  performance_id: opening_perf_id
})

Repo.insert!(%SubscriptionHolding{
  subscription_id: subscription_id,
  audience_member_id: patron_a_id,
  acquired_at: now,
  status: :active
})

# ---- 23. Secrets: API key + door badge ----

Repo.insert!(%ApiKey{
  name: "baton-connector primary",
  identity_id: sync_bot_id,
  created_by_id: marin_id,
  hashed_secret: "sha256:" <> Base.encode16(:crypto.hash(:sha256, "demo-secret"), case: :lower)
})

Repo.insert!(%DoorBadge{
  badge_number: "BADGE-001",
  identity_id: stage_mgr_id,
  venue_id: hall_id,
  issued_at: now,
  status: :active
})

# ---- 24. Security finding (overdue checkout signal) ----

Repo.insert!(%Finding{
  subject_resource_kind: "musician",
  subject_resource_id: hilary_id,
  severity: :medium,
  finding_type: "high_value_instrument_assignment",
  details: %{"instrument_id" => stradivarius_id, "value_cents" => 1_500_000_000},
  detected_at: now
})

# ---- 25. Request schemas (the SDK ticketing capability) ----

%{id: refund_schema_id} =
  Repo.insert!(%Schema{
    slug: "ticket_refund_dispute",
    display_name: "Ticket Refund Dispute",
    types: [%{"id" => "refund", "display_name" => "Refund Request"}],
    statuses: [
      %{"id" => "open", "display_name" => "Open"},
      %{"id" => "approved", "display_name" => "Approved"},
      %{"id" => "denied", "display_name" => "Denied"}
    ]
  })

for {fid, name, kind, config} <- [
      {"order_number", "Order Number", :string, %{}},
      {"reason", "Reason", :pick_string,
       %{
         "allowed_values" => [
           "could_not_attend",
           "duplicate_purchase",
           "performance_cancelled",
           "other"
         ]
       }},
      {"requested_amount_cents", "Requested Amount (cents)", :number, %{}}
    ] do
  Repo.insert!(%CustomFieldDef{
    schema_id: refund_schema_id,
    field_id: fid,
    display_name: name,
    required: fid == "order_number",
    field_kind: kind,
    config: config
  })
end

%{id: a11y_schema_id} =
  Repo.insert!(%Schema{
    slug: "accessibility_request",
    display_name: "Accessibility Request",
    types: [%{"id" => "default", "display_name" => "Accessibility"}],
    statuses: [
      %{"id" => "open", "display_name" => "Open"},
      %{"id" => "fulfilled", "display_name" => "Fulfilled"}
    ]
  })

Repo.insert!(%CustomFieldDef{
  schema_id: a11y_schema_id,
  field_id: "accommodation_type",
  display_name: "Accommodation Needed",
  required: true,
  field_kind: :pick_multi_string,
  config: %{
    "allowed_values" => [
      "wheelchair",
      "companion_seat",
      "large_print_program",
      "hearing_loop",
      "asl_interpreter"
    ]
  }
})

# ---- 26. Audit events (kicks the event-feed cursor) ----

Repo.insert!(%Event{
  occurred_at: now,
  event_type: :create_grant,
  actor_resource_kind: "musician",
  actor_resource_id: marin_id,
  target_resource_kind: "season_subscription",
  target_resource_id: subscription_id,
  entitlement_slug: "season_subscription:holder",
  payload: %{"audience_member_id" => patron_a_id}
})

Repo.insert!(%Event{
  occurred_at: now,
  event_type: :create_grant,
  actor_resource_kind: "musician",
  actor_resource_id: marin_id,
  target_resource_kind: "performance",
  target_resource_id: opening_perf_id,
  entitlement_slug: "performance:attend",
  payload: %{"audience_member_id" => patron_a_id, "seat_id" => a1_seat.id}
})

# ---- 27. Action invocation log entry ----

Repo.insert!(%Invocation{
  id: "act_" <> Base.encode16(:crypto.strong_rand_bytes(8), case: :lower),
  action_name: "performance.publish",
  resource_type_id: "performance",
  resource_id: opening_perf_id,
  args: %{},
  status: :complete,
  response: %{"new_status" => "on_sale"},
  invoked_by_id: marin_id,
  invoked_at: now,
  finished_at: now
})

IO.puts("Seeded.")
