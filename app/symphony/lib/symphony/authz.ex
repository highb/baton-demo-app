defmodule Symphony.Authz do
  @moduledoc """
  Permission checks against the seeded RBAC tables (`roles`, `permissions`,
  `role_permissions`, `role_assignments`).

  Resolution: an actor has a permission if any of their role assignments
  links to a role that includes the permission slug. Role-scope-bindings
  are NOT consulted here yet — `has_permission?/2` answers the global
  question. Scope-aware checks come later when we have endpoints that
  need them.
  """

  import Ecto.Query

  alias Symphony.Identity.Musician
  alias Symphony.Rbac.{RoleAssignment, RolePermission, Permission}
  alias Symphony.Repo

  @doc "True if the actor holds the named permission via any of their roles."
  def has_permission?(%Musician{id: actor_id}, slug) when is_binary(slug) do
    query =
      from a in RoleAssignment,
        where: a.musician_id == ^actor_id,
        join: rp in RolePermission,
        on: rp.role_id == a.role_id,
        join: p in Permission,
        on: p.id == rp.permission_id,
        where: p.slug == ^slug,
        select: 1,
        limit: 1

    Repo.exists?(query)
  end

  def has_permission?(_, _), do: false

  @doc "All permission slugs the actor holds via any of their roles. Returns sorted, distinct."
  def list_permissions(%Musician{id: actor_id}) do
    query =
      from a in RoleAssignment,
        where: a.musician_id == ^actor_id,
        join: rp in RolePermission,
        on: rp.role_id == a.role_id,
        join: p in Permission,
        on: p.id == rp.permission_id,
        select: p.slug,
        distinct: true,
        order_by: p.slug

    Repo.all(query)
  end

  def list_permissions(_), do: []
end
