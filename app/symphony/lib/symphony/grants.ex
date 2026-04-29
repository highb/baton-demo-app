defmodule Symphony.Grants do
  @moduledoc """
  Builds a unified grants view by joining each entitlement-bearing source
  table to its principals. baton-sdk's connector calls this per resource
  to enumerate grants; we dispatch by `resource_type` to the right source.

  Source tables per resource_type:

    * `role` — `role_assignments`
    * `section` — `section_memberships` (member + principal)
    * `ensemble` — `ensemble_memberships` (member + concertmaster heuristic)
    * `application` — `application_assignments`
    * `instrument` — `resource_owners` + `instrument_checkouts` (open)
    * `equipment` — `equipment_checkouts` (open)
    * `sheet_music` — `resource_owners` + `sheet_music_access`
    * `performance` — `tickets` (status sold/used/comped)
    * `season_subscription` — `subscription_holdings` (active)

  Other resource types currently have no grants in the data model.
  """

  import Ecto.Query
  alias Symphony.Repo

  alias Symphony.Identity.{Musician, AudienceMember}
  alias Symphony.Orchestra.{SectionMembership, EnsembleMembership}
  alias Symphony.Rbac.{RoleAssignment, ApplicationAssignment, ResourceOwner}
  alias Symphony.Checkouts.{InstrumentCheckout, EquipmentCheckout, SheetMusicAccess}
  alias Symphony.Ticketing.{Ticket, SubscriptionHolding}

  @doc """
  Lists grants whose target is the given (resource_type, resource_id).
  Returns plain maps shaped for JSON rendering.
  """
  def list_for_resource(resource_type, resource_id) when is_binary(resource_type) do
    do_list(resource_type, resource_id)
  end

  defp do_list("role", role_id) do
    from(a in RoleAssignment,
      where: a.role_id == ^role_id,
      preload: [:musician, :audience_member]
    )
    |> Repo.all()
    |> Enum.map(&role_assignment_grant/1)
  end

  defp do_list("section", section_id) do
    from(m in SectionMembership,
      where: m.section_id == ^section_id,
      preload: :musician
    )
    |> Repo.all()
    |> Enum.flat_map(&section_membership_grants/1)
  end

  defp do_list("ensemble", ensemble_id) do
    from(m in EnsembleMembership,
      where: m.ensemble_id == ^ensemble_id,
      preload: :musician
    )
    |> Repo.all()
    |> Enum.flat_map(&ensemble_membership_grants/1)
  end

  defp do_list("application", app_id) do
    from(a in ApplicationAssignment,
      where: a.application_id == ^app_id,
      preload: :musician
    )
    |> Repo.all()
    |> Enum.map(&application_assignment_grant/1)
  end

  defp do_list("instrument", instrument_id) do
    owner_grants = ownership_grants("instrument", instrument_id)

    checkout_grants =
      from(c in InstrumentCheckout,
        where: c.instrument_id == ^instrument_id,
        where: is_nil(c.returned_at),
        preload: :musician
      )
      |> Repo.all()
      |> Enum.map(&instrument_checkout_grant/1)

    owner_grants ++ checkout_grants
  end

  defp do_list("equipment", equipment_id) do
    from(c in EquipmentCheckout,
      where: c.equipment_id == ^equipment_id,
      where: is_nil(c.returned_at),
      preload: :musician
    )
    |> Repo.all()
    |> Enum.map(&equipment_checkout_grant/1)
  end

  defp do_list("sheet_music", sheet_id) do
    owner_grants = ownership_grants("sheet_music", sheet_id)

    access_grants =
      from(a in SheetMusicAccess,
        where: a.sheet_music_id == ^sheet_id,
        preload: :musician
      )
      |> Repo.all()
      |> Enum.map(&sheet_music_access_grant/1)

    owner_grants ++ access_grants
  end

  defp do_list("performance", perf_id) do
    from(t in Ticket,
      where: t.performance_id == ^perf_id,
      where: t.status in [:sold, :used, :comped],
      preload: :audience_member
    )
    |> Repo.all()
    |> Enum.map(&ticket_grant/1)
  end

  defp do_list("season_subscription", sub_id) do
    from(h in SubscriptionHolding,
      where: h.subscription_id == ^sub_id,
      where: h.status == :active,
      preload: :audience_member
    )
    |> Repo.all()
    |> Enum.map(&subscription_holding_grant/1)
  end

  defp do_list(_, _), do: []

  # ---- Per-source grant builders ----

  defp role_assignment_grant(%RoleAssignment{} = a) do
    {principal_type, principal} =
      cond do
        a.musician -> {"musician", a.musician}
        a.audience_member -> {"audience_member", a.audience_member}
      end

    grant(
      "role_assignments:#{a.id}",
      "role:member",
      "role",
      a.role_id,
      principal_type,
      principal,
      "role_assignments"
    )
  end

  defp section_membership_grants(%SectionMembership{is_principal: true} = m) do
    [
      grant("section_memberships:#{m.section_id}:#{m.musician_id}:member",
        "section:member", "section", m.section_id, "musician", m.musician,
        "section_memberships"),
      grant("section_memberships:#{m.section_id}:#{m.musician_id}:principal",
        "section:principal", "section", m.section_id, "musician", m.musician,
        "section_memberships")
    ]
  end

  defp section_membership_grants(%SectionMembership{} = m) do
    [
      grant("section_memberships:#{m.section_id}:#{m.musician_id}",
        "section:member", "section", m.section_id, "musician", m.musician,
        "section_memberships")
    ]
  end

  defp ensemble_membership_grants(%EnsembleMembership{chair_position: 1} = m) do
    [
      grant("ensemble_memberships:#{m.ensemble_id}:#{m.musician_id}:member",
        "ensemble:member", "ensemble", m.ensemble_id, "musician", m.musician,
        "ensemble_memberships"),
      grant("ensemble_memberships:#{m.ensemble_id}:#{m.musician_id}:concertmaster",
        "ensemble:concertmaster", "ensemble", m.ensemble_id, "musician", m.musician,
        "ensemble_memberships")
    ]
  end

  defp ensemble_membership_grants(%EnsembleMembership{} = m) do
    [
      grant("ensemble_memberships:#{m.ensemble_id}:#{m.musician_id}",
        "ensemble:member", "ensemble", m.ensemble_id, "musician", m.musician,
        "ensemble_memberships")
    ]
  end

  defp application_assignment_grant(%ApplicationAssignment{} = a) do
    grant(
      "application_assignments:#{a.application_id}:#{a.musician_id}",
      "application:assigned",
      "application",
      a.application_id,
      "musician",
      a.musician,
      "application_assignments"
    )
  end

  defp instrument_checkout_grant(%InstrumentCheckout{} = c) do
    grant(
      "instrument_checkouts:#{c.id}",
      "instrument:checkout",
      "instrument",
      c.instrument_id,
      "musician",
      c.musician,
      "instrument_checkouts"
    )
  end

  defp equipment_checkout_grant(%EquipmentCheckout{} = c) do
    grant(
      "equipment_checkouts:#{c.id}",
      "equipment:checkout",
      "equipment",
      c.equipment_id,
      "musician",
      c.musician,
      "equipment_checkouts"
    )
  end

  defp sheet_music_access_grant(%SheetMusicAccess{} = a) do
    grant(
      "sheet_music_access:#{a.id}",
      "sheet_music:read",
      "sheet_music",
      a.sheet_music_id,
      "musician",
      a.musician,
      "sheet_music_access"
    )
  end

  defp ticket_grant(%Ticket{audience_member: nil}), do: nil

  defp ticket_grant(%Ticket{} = t) do
    grant(
      "tickets:#{t.id}",
      "performance:attend",
      "performance",
      t.performance_id,
      "audience_member",
      t.audience_member,
      "tickets"
    )
  end

  defp subscription_holding_grant(%SubscriptionHolding{} = h) do
    grant(
      "subscription_holdings:#{h.id}",
      "season_subscription:holder",
      "season_subscription",
      h.subscription_id,
      "audience_member",
      h.audience_member,
      "subscription_holdings"
    )
  end

  defp ownership_grants(resource_kind, resource_id) do
    from(o in ResourceOwner,
      where: o.resource_kind == ^resource_kind,
      where: o.resource_id == ^resource_id,
      preload: :musician
    )
    |> Repo.all()
    |> Enum.map(fn %ResourceOwner{} = o ->
      slug =
        case o.ownership_type do
          :primary -> "#{resource_kind}:owner"
          :secondary -> "#{resource_kind}:owner"
          :curator -> "#{resource_kind}:curator"
        end

      grant(
        "resource_owners:#{o.id}",
        slug,
        resource_kind,
        resource_id,
        "musician",
        o.musician,
        "resource_owners"
      )
    end)
  end

  # ---- Wire format ----

  defp grant(id, entitlement_slug, resource_type, resource_id, principal_type, principal, source) do
    %{
      id: id,
      entitlement: %{
        slug: entitlement_slug,
        resource: %{resource_type: resource_type, id: resource_id}
      },
      principal: principal_payload(principal_type, principal),
      sources: %{source => %{is_direct: true}}
    }
  end

  defp principal_payload("musician", %Musician{} = m) do
    %{
      resource_type: "musician",
      id: m.id,
      display_name: musician_display_name(m),
      login: m.login
    }
  end

  defp principal_payload("audience_member", %AudienceMember{} = a) do
    %{
      resource_type: "audience_member",
      id: a.id,
      display_name: audience_display_name(a),
      login: a.login
    }
  end

  defp musician_display_name(m) do
    case [m.given_name, m.family_name] |> Enum.reject(&is_nil/1) do
      [] -> m.login
      parts -> Enum.join(parts, " ")
    end
  end

  defp audience_display_name(a) do
    case [a.given_name, a.family_name] |> Enum.reject(&is_nil/1) do
      [] -> a.login
      parts -> Enum.join(parts, " ")
    end
  end
end
