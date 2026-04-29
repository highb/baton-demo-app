defmodule Symphony.Rbac.ResourceOwner do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician

  @ownership_types ~w(primary secondary curator)a

  schema "resource_owners" do
    field :resource_kind, :string
    field :resource_id, :integer
    field :ownership_type, Ecto.Enum, values: @ownership_types

    belongs_to :musician, Musician

    timestamps(type: :utc_datetime)
  end

  @castable ~w(resource_kind resource_id musician_id ownership_type)a

  def changeset(owner, attrs) do
    owner
    |> cast(attrs, @castable)
    |> validate_required(@castable)
    |> unique_constraint([:resource_kind, :resource_id, :musician_id, :ownership_type])
  end
end
