defmodule Symphony.Rbac.RoleScopeBinding do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Rbac.Role

  @scope_kinds ~w(section ensemble venue)

  schema "role_scope_bindings" do
    field :scope_resource_kind, :string
    field :scope_resource_id, :integer

    belongs_to :role, Role

    timestamps(type: :utc_datetime)
  end

  def changeset(binding, attrs) do
    binding
    |> cast(attrs, [:role_id, :scope_resource_kind, :scope_resource_id])
    |> validate_required([:role_id, :scope_resource_kind, :scope_resource_id])
    |> validate_inclusion(:scope_resource_kind, @scope_kinds)
    |> unique_constraint([:role_id, :scope_resource_kind, :scope_resource_id])
  end
end
