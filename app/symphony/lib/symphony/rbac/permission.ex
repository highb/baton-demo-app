defmodule Symphony.Rbac.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :slug, :string
    field :resource_kind, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:slug, :resource_kind, :description])
    |> validate_required([:slug, :resource_kind])
    |> unique_constraint(:slug)
  end
end
