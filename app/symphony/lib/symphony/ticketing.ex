defmodule Symphony.Ticketing do
  @moduledoc """
  The Ticketing context.
  """

  import Ecto.Query, warn: false
  alias Symphony.Repo

  alias Symphony.Ticketing.{
    PriceTier,
    PromoCode,
    VenueSection,
    SeasonSubscription
  }

  # ---- Price tiers ----

  def list_price_tiers do
    Repo.all(from t in PriceTier, order_by: [asc: t.slug])
  end

  def get_price_tier!(id), do: Repo.get!(PriceTier, id)

  def create_price_tier(attrs) do
    %PriceTier{}
    |> PriceTier.changeset(attrs)
    |> Repo.insert()
  end

  def update_price_tier(%PriceTier{} = price_tier, attrs) do
    price_tier
    |> PriceTier.changeset(attrs)
    |> Repo.update()
  end

  def delete_price_tier(%PriceTier{} = price_tier), do: Repo.delete(price_tier)

  def change_price_tier(%PriceTier{} = price_tier, attrs \\ %{}) do
    PriceTier.changeset(price_tier, attrs)
  end

  # ---- Promo codes ----

  def list_promo_codes do
    Repo.all(from p in PromoCode, order_by: [asc: p.code])
  end

  def get_promo_code!(id), do: Repo.get!(PromoCode, id)

  def create_promo_code(attrs) do
    %PromoCode{}
    |> PromoCode.changeset(attrs)
    |> Repo.insert()
  end

  def update_promo_code(%PromoCode{} = promo_code, attrs) do
    promo_code
    |> PromoCode.changeset(attrs)
    |> Repo.update()
  end

  def delete_promo_code(%PromoCode{} = promo_code), do: Repo.delete(promo_code)

  def change_promo_code(%PromoCode{} = promo_code, attrs \\ %{}) do
    PromoCode.changeset(promo_code, attrs)
  end

  # ---- Venue sections ----

  def list_venue_sections do
    Repo.all(from s in VenueSection, order_by: [asc: s.venue_id, asc: s.display_order])
  end

  def get_venue_section!(id), do: Repo.get!(VenueSection, id)

  def create_venue_section(attrs) do
    %VenueSection{}
    |> VenueSection.changeset(attrs)
    |> Repo.insert()
  end

  def update_venue_section(%VenueSection{} = venue_section, attrs) do
    venue_section
    |> VenueSection.changeset(attrs)
    |> Repo.update()
  end

  def delete_venue_section(%VenueSection{} = venue_section), do: Repo.delete(venue_section)

  def change_venue_section(%VenueSection{} = venue_section, attrs \\ %{}) do
    VenueSection.changeset(venue_section, attrs)
  end

  # ---- Season subscriptions ----

  def list_season_subscriptions do
    Repo.all(from s in SeasonSubscription, order_by: [asc: s.slug])
  end

  def get_season_subscription!(id), do: Repo.get!(SeasonSubscription, id)

  def create_season_subscription(attrs) do
    %SeasonSubscription{}
    |> SeasonSubscription.changeset(attrs)
    |> Repo.insert()
  end

  def update_season_subscription(%SeasonSubscription{} = season_subscription, attrs) do
    season_subscription
    |> SeasonSubscription.changeset(attrs)
    |> Repo.update()
  end

  def delete_season_subscription(%SeasonSubscription{} = season_subscription),
    do: Repo.delete(season_subscription)

  def change_season_subscription(%SeasonSubscription{} = season_subscription, attrs \\ %{}) do
    SeasonSubscription.changeset(season_subscription, attrs)
  end
end
