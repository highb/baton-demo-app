defmodule Symphony.Ticketing.PriceTier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "price_tiers" do
    field :slug, :string
    field :display_name, :string
    field :is_comp, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(tier, attrs) do
    tier
    |> cast(attrs, [:slug, :display_name, :is_comp])
    |> validate_required([:slug, :display_name])
    |> unique_constraint(:slug)
  end
end
