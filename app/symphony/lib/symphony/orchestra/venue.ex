defmodule Symphony.Orchestra.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venues" do
    field :name, :string
    field :address, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:name, :address])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
