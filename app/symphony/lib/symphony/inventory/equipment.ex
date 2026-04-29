defmodule Symphony.Inventory.Equipment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Orchestra.Venue

  @statuses ~w(available checked_out maintenance retired)a

  schema "equipment" do
    field :asset_tag, :string
    field :category, :string
    field :description, :string
    field :status, Ecto.Enum, values: @statuses, default: :available

    belongs_to :storage_venue, Venue, foreign_key: :storage_venue_id

    timestamps(type: :utc_datetime)
  end

  def changeset(equipment, attrs) do
    equipment
    |> cast(attrs, [:asset_tag, :category, :description, :status, :storage_venue_id])
    |> validate_required([:asset_tag, :category, :status])
    |> unique_constraint(:asset_tag)
  end
end
