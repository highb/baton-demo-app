defmodule Symphony.Rbac.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Rbac.{Role, Permission}

  @primary_key false
  schema "role_permissions" do
    belongs_to :role, Role, primary_key: true
    belongs_to :permission, Permission, primary_key: true

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(rp, attrs) do
    rp
    |> cast(attrs, [:role_id, :permission_id])
    |> validate_required([:role_id, :permission_id])
  end
end
