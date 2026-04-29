defmodule Symphony.Rbac.RoleAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.{Musician, AudienceMember}
  alias Symphony.Rbac.Role

  schema "role_assignments" do
    field :granted_at, :utc_datetime
    field :expires_at, :utc_datetime

    belongs_to :role, Role
    belongs_to :musician, Musician
    belongs_to :audience_member, AudienceMember
    belongs_to :granted_by, Musician, foreign_key: :granted_by_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(role_id musician_id audience_member_id granted_at granted_by_id expires_at)a

  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, @castable)
    |> validate_required([:role_id, :granted_at])
    |> validate_principal_set()
  end

  defp validate_principal_set(changeset) do
    musician = get_field(changeset, :musician_id)
    audience = get_field(changeset, :audience_member_id)

    case {musician, audience} do
      {nil, nil} ->
        add_error(changeset, :musician_id, "either musician_id or audience_member_id is required")

      {m, a} when not is_nil(m) and not is_nil(a) ->
        add_error(changeset, :musician_id, "cannot set both musician_id and audience_member_id")

      _ ->
        changeset
    end
  end
end
