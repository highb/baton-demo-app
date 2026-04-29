defmodule Symphony.TicketingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Symphony.Ticketing` context.
  """

  @doc """
  Generate a price_tier.
  """
  def price_tier_fixture(attrs \\ %{}) do
    {:ok, price_tier} =
      attrs
      |> Enum.into(%{
        display_name: "some display_name",
        is_comp: true,
        slug: "some slug"
      })
      |> Symphony.Ticketing.create_price_tier()

    price_tier
  end

  @doc """
  Generate a promo_code.
  """
  def promo_code_fixture(attrs \\ %{}) do
    {:ok, promo_code} =
      attrs
      |> Enum.into(%{
        active: true,
        applies_to_performance_id: 42,
        code: "some code",
        current_redemptions: 42,
        discount_kind: "some discount_kind",
        discount_value: 42,
        display_name: "some display_name",
        max_redemptions: 42,
        min_total_cents: 42
      })
      |> Symphony.Ticketing.create_promo_code()

    promo_code
  end

  @doc """
  Generate a venue_section.
  """
  def venue_section_fixture(attrs \\ %{}) do
    {:ok, venue_section} =
      attrs
      |> Enum.into(%{
        capacity: 42,
        display_order: 42,
        name: "some name",
        venue_id: 42
      })
      |> Symphony.Ticketing.create_venue_section()

    venue_section
  end

  @doc """
  Generate a season_subscription.
  """
  def season_subscription_fixture(attrs \\ %{}) do
    {:ok, season_subscription} =
      attrs
      |> Enum.into(%{
        active: true,
        base_price_cents: 42,
        description: "some description",
        display_name: "some display_name",
        ensemble_id: 42,
        slug: "some slug",
        total_seats_per_holder: 42
      })
      |> Symphony.Ticketing.create_season_subscription()

    season_subscription
  end
end
