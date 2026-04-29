defmodule Symphony.Checkouts.InstrumentCheckout do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Inventory.Instrument

  schema "instrument_checkouts" do
    field :checked_out_at, :utc_datetime
    field :due_at, :utc_datetime
    field :returned_at, :utc_datetime
    field :condition_out, :string
    field :condition_in, :string
    field :notes, :string

    belongs_to :instrument, Instrument
    belongs_to :musician, Musician

    timestamps(type: :utc_datetime)
  end

  @castable ~w(instrument_id musician_id checked_out_at due_at returned_at
               condition_out condition_in notes)a

  def changeset(checkout, attrs) do
    checkout
    |> cast(attrs, @castable)
    |> validate_required([:instrument_id, :musician_id, :checked_out_at, :due_at, :condition_out])
  end
end
