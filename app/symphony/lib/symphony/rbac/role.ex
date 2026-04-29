defmodule Symphony.Rbac.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Rbac.{Permission, RolePermission, RoleAssignment, RoleScopeBinding}

  schema "roles" do
    field :slug, :string
    field :display_name, :string
    field :description, :string
    field :profile, :map, default: %{}

    has_many :role_permissions, RolePermission
    many_to_many :permissions, Permission, join_through: RolePermission
    has_many :assignments, RoleAssignment
    has_many :scope_bindings, RoleScopeBinding

    timestamps(type: :utc_datetime)
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:slug, :display_name, :description, :profile])
    |> validate_required([:slug, :display_name])
    |> unique_constraint(:slug)
  end
end
