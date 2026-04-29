defmodule Symphony.Checkouts.EquipmentCheckout do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Inventory.Equipment

  schema "equipment_checkouts" do
    field :checked_out_at, :utc_datetime
    field :due_at, :utc_datetime
    field :returned_at, :utc_datetime

    belongs_to :equipment, Equipment
    belongs_to :musician, Musician

    timestamps(type: :utc_datetime)
  end

  @castable ~w(equipment_id musician_id checked_out_at due_at returned_at)a

  def changeset(checkout, attrs) do
    checkout
    |> cast(attrs, @castable)
    |> validate_required([:equipment_id, :musician_id, :checked_out_at, :due_at])
  end
end
