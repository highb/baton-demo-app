defmodule Symphony.Inventory.Instrument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Orchestra.Venue

  @families ~w(strings woodwinds brass percussion keys voice other)
  @conditions ~w(new excellent good fair poor needs_repair)a
  @statuses ~w(available checked_out maintenance retired)a

  schema "instruments" do
    field :asset_tag, :string
    field :family, :string
    field :kind, :string
    field :manufacturer, :string
    field :model, :string
    field :serial_number, :string
    field :acquisition_value_cents, :integer
    field :condition, Ecto.Enum, values: @conditions
    field :status, Ecto.Enum, values: @statuses, default: :available
    field :notes, :string

    belongs_to :storage_venue, Venue, foreign_key: :storage_venue_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(asset_tag family kind manufacturer model serial_number
               acquisition_value_cents condition status storage_venue_id notes)a

  def changeset(instrument, attrs) do
    instrument
    |> cast(attrs, @castable)
    |> validate_required([:asset_tag, :family, :kind, :condition, :status])
    |> validate_inclusion(:family, @families)
    |> unique_constraint(:asset_tag)
  end
end
