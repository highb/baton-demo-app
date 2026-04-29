defmodule Symphony.Catalog do
  @moduledoc """
  Static metadata describing the resource types and entitlements Symphony
  exposes. baton-sdk treats this as connector-declared (it's not stored in
  the same tables as the data itself), so it lives as code.

  See `docs/database-design.md` §6 for the entitlement catalog rationale.
  """

  @resource_types [
    %{id: "musician", display_name: "Musician", traits: ["user"]},
    %{id: "audience_member", display_name: "Audience Member", traits: ["user"]},
    %{id: "section", display_name: "Section", traits: ["group"]},
    %{id: "ensemble", display_name: "Ensemble", traits: ["group"]},
    %{id: "role", display_name: "Role", traits: ["role"]},
    %{id: "application", display_name: "Application", traits: ["app"]},
    %{id: "api_key", display_name: "API Key", traits: ["secret"]},
    %{id: "door_badge", display_name: "Door Badge", traits: ["secret"]},
    %{id: "security_finding", display_name: "Security Finding", traits: ["security_insight"]},
    %{id: "role_scope_binding", display_name: "Role Scope Binding", traits: ["scope_binding"]},
    %{id: "instrument", display_name: "Instrument", traits: []},
    %{id: "equipment", display_name: "Equipment", traits: []},
    %{id: "sheet_music", display_name: "Sheet Music", traits: []},
    %{id: "venue", display_name: "Venue", traits: []},
    %{id: "venue_section", display_name: "Venue Section", traits: []},
    %{id: "seat", display_name: "Seat", traits: []},
    %{id: "performance", display_name: "Performance", traits: []},
    %{id: "season_subscription", display_name: "Season Subscription", traits: []},
    %{id: "promo_code", display_name: "Promo Code", traits: []}
  ]

  @entitlements [
    # Role membership — assignment purpose, grantable to either user trait.
    %{slug: "role:member", resource_type: "role", purpose: "assignment",
      grantable_to: ["musician", "audience_member"], display_name: "Member"},

    # Section / ensemble membership and principal positions.
    %{slug: "section:member", resource_type: "section", purpose: "assignment",
      grantable_to: ["musician"], display_name: "Member"},
    %{slug: "section:principal", resource_type: "section", purpose: "assignment",
      grantable_to: ["musician"], display_name: "Principal"},
    %{slug: "ensemble:member", resource_type: "ensemble", purpose: "assignment",
      grantable_to: ["musician"], display_name: "Member"},
    %{slug: "ensemble:concertmaster", resource_type: "ensemble", purpose: "assignment",
      grantable_to: ["musician"], display_name: "Concertmaster"},

    # Application access.
    %{slug: "application:assigned", resource_type: "application", purpose: "assignment",
      grantable_to: ["musician"], display_name: "Assigned"},

    # Operational permissions on physical resources.
    %{slug: "instrument:checkout", resource_type: "instrument", purpose: "permission",
      grantable_to: ["musician"], display_name: "Checkout"},
    %{slug: "equipment:checkout", resource_type: "equipment", purpose: "permission",
      grantable_to: ["musician"], display_name: "Checkout"},
    %{slug: "sheet_music:read", resource_type: "sheet_music", purpose: "permission",
      grantable_to: ["musician"], display_name: "Read"},

    # Performance + ticketing.
    %{slug: "performance:attend", resource_type: "performance", purpose: "permission",
      grantable_to: ["audience_member"], display_name: "Attend"},
    %{slug: "performance:box_office_manage", resource_type: "performance", purpose: "permission",
      grantable_to: ["musician"], display_name: "Box-office manage"},
    %{slug: "venue_section:usher", resource_type: "venue_section", purpose: "permission",
      grantable_to: ["musician"], display_name: "Usher"},
    %{slug: "season_subscription:holder", resource_type: "season_subscription", purpose: "assignment",
      grantable_to: ["audience_member"], display_name: "Holder"},
    %{slug: "promo_code:redeem", resource_type: "promo_code", purpose: "permission",
      grantable_to: ["audience_member"], display_name: "Redeem"},

    # Ownership entitlements.
    %{slug: "instrument:owner", resource_type: "instrument", purpose: "ownership",
      grantable_to: ["musician"], display_name: "Primary owner"},
    %{slug: "instrument:curator", resource_type: "instrument", purpose: "ownership",
      grantable_to: ["musician"], display_name: "Curator"},
    %{slug: "sheet_music:owner", resource_type: "sheet_music", purpose: "ownership",
      grantable_to: ["musician"], display_name: "Primary owner"},
    %{slug: "sheet_music:curator", resource_type: "sheet_music", purpose: "ownership",
      grantable_to: ["musician"], display_name: "Curator"},
    %{slug: "ensemble:owner", resource_type: "ensemble", purpose: "ownership",
      grantable_to: ["musician"], display_name: "Primary owner"},
    %{slug: "ensemble:curator", resource_type: "ensemble", purpose: "ownership",
      grantable_to: ["musician"], display_name: "Curator"}
  ]

  def list_resource_types, do: @resource_types

  def list_entitlements(opts \\ []) do
    case Keyword.get(opts, :resource_type) do
      nil -> @entitlements
      type -> Enum.filter(@entitlements, &(&1.resource_type == type))
    end
  end
end
