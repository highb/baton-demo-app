defmodule Symphony.TicketingTest do
  use Symphony.DataCase

  alias Symphony.Ticketing

  describe "price_tiers" do
    alias Symphony.Ticketing.PriceTier

    import Symphony.TicketingFixtures

    @invalid_attrs %{slug: nil, display_name: nil, is_comp: nil}

    test "list_price_tiers/0 returns all price_tiers" do
      price_tier = price_tier_fixture()
      assert Ticketing.list_price_tiers() == [price_tier]
    end

    test "get_price_tier!/1 returns the price_tier with given id" do
      price_tier = price_tier_fixture()
      assert Ticketing.get_price_tier!(price_tier.id) == price_tier
    end

    test "create_price_tier/1 with valid data creates a price_tier" do
      valid_attrs = %{slug: "some slug", display_name: "some display_name", is_comp: true}

      assert {:ok, %PriceTier{} = price_tier} = Ticketing.create_price_tier(valid_attrs)
      assert price_tier.slug == "some slug"
      assert price_tier.display_name == "some display_name"
      assert price_tier.is_comp == true
    end

    test "create_price_tier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticketing.create_price_tier(@invalid_attrs)
    end

    test "update_price_tier/2 with valid data updates the price_tier" do
      price_tier = price_tier_fixture()
      update_attrs = %{slug: "some updated slug", display_name: "some updated display_name", is_comp: false}

      assert {:ok, %PriceTier{} = price_tier} = Ticketing.update_price_tier(price_tier, update_attrs)
      assert price_tier.slug == "some updated slug"
      assert price_tier.display_name == "some updated display_name"
      assert price_tier.is_comp == false
    end

    test "update_price_tier/2 with invalid data returns error changeset" do
      price_tier = price_tier_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticketing.update_price_tier(price_tier, @invalid_attrs)
      assert price_tier == Ticketing.get_price_tier!(price_tier.id)
    end

    test "delete_price_tier/1 deletes the price_tier" do
      price_tier = price_tier_fixture()
      assert {:ok, %PriceTier{}} = Ticketing.delete_price_tier(price_tier)
      assert_raise Ecto.NoResultsError, fn -> Ticketing.get_price_tier!(price_tier.id) end
    end

    test "change_price_tier/1 returns a price_tier changeset" do
      price_tier = price_tier_fixture()
      assert %Ecto.Changeset{} = Ticketing.change_price_tier(price_tier)
    end
  end

  describe "promo_codes" do
    alias Symphony.Ticketing.PromoCode

    import Symphony.TicketingFixtures

    @invalid_attrs %{active: nil, code: nil, display_name: nil, discount_kind: nil, discount_value: nil, min_total_cents: nil, max_redemptions: nil, current_redemptions: nil, applies_to_performance_id: nil}

    test "list_promo_codes/0 returns all promo_codes" do
      promo_code = promo_code_fixture()
      assert Ticketing.list_promo_codes() == [promo_code]
    end

    test "get_promo_code!/1 returns the promo_code with given id" do
      promo_code = promo_code_fixture()
      assert Ticketing.get_promo_code!(promo_code.id) == promo_code
    end

    test "create_promo_code/1 with valid data creates a promo_code" do
      valid_attrs = %{active: true, code: "some code", display_name: "some display_name", discount_kind: "some discount_kind", discount_value: 42, min_total_cents: 42, max_redemptions: 42, current_redemptions: 42, applies_to_performance_id: 42}

      assert {:ok, %PromoCode{} = promo_code} = Ticketing.create_promo_code(valid_attrs)
      assert promo_code.active == true
      assert promo_code.code == "some code"
      assert promo_code.display_name == "some display_name"
      assert promo_code.discount_kind == "some discount_kind"
      assert promo_code.discount_value == 42
      assert promo_code.min_total_cents == 42
      assert promo_code.max_redemptions == 42
      assert promo_code.current_redemptions == 42
      assert promo_code.applies_to_performance_id == 42
    end

    test "create_promo_code/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticketing.create_promo_code(@invalid_attrs)
    end

    test "update_promo_code/2 with valid data updates the promo_code" do
      promo_code = promo_code_fixture()
      update_attrs = %{active: false, code: "some updated code", display_name: "some updated display_name", discount_kind: "some updated discount_kind", discount_value: 43, min_total_cents: 43, max_redemptions: 43, current_redemptions: 43, applies_to_performance_id: 43}

      assert {:ok, %PromoCode{} = promo_code} = Ticketing.update_promo_code(promo_code, update_attrs)
      assert promo_code.active == false
      assert promo_code.code == "some updated code"
      assert promo_code.display_name == "some updated display_name"
      assert promo_code.discount_kind == "some updated discount_kind"
      assert promo_code.discount_value == 43
      assert promo_code.min_total_cents == 43
      assert promo_code.max_redemptions == 43
      assert promo_code.current_redemptions == 43
      assert promo_code.applies_to_performance_id == 43
    end

    test "update_promo_code/2 with invalid data returns error changeset" do
      promo_code = promo_code_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticketing.update_promo_code(promo_code, @invalid_attrs)
      assert promo_code == Ticketing.get_promo_code!(promo_code.id)
    end

    test "delete_promo_code/1 deletes the promo_code" do
      promo_code = promo_code_fixture()
      assert {:ok, %PromoCode{}} = Ticketing.delete_promo_code(promo_code)
      assert_raise Ecto.NoResultsError, fn -> Ticketing.get_promo_code!(promo_code.id) end
    end

    test "change_promo_code/1 returns a promo_code changeset" do
      promo_code = promo_code_fixture()
      assert %Ecto.Changeset{} = Ticketing.change_promo_code(promo_code)
    end
  end

  describe "venue_sections" do
    alias Symphony.Ticketing.VenueSection

    import Symphony.TicketingFixtures

    @invalid_attrs %{name: nil, venue_id: nil, display_order: nil, capacity: nil}

    test "list_venue_sections/0 returns all venue_sections" do
      venue_section = venue_section_fixture()
      assert Ticketing.list_venue_sections() == [venue_section]
    end

    test "get_venue_section!/1 returns the venue_section with given id" do
      venue_section = venue_section_fixture()
      assert Ticketing.get_venue_section!(venue_section.id) == venue_section
    end

    test "create_venue_section/1 with valid data creates a venue_section" do
      valid_attrs = %{name: "some name", venue_id: 42, display_order: 42, capacity: 42}

      assert {:ok, %VenueSection{} = venue_section} = Ticketing.create_venue_section(valid_attrs)
      assert venue_section.name == "some name"
      assert venue_section.venue_id == 42
      assert venue_section.display_order == 42
      assert venue_section.capacity == 42
    end

    test "create_venue_section/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticketing.create_venue_section(@invalid_attrs)
    end

    test "update_venue_section/2 with valid data updates the venue_section" do
      venue_section = venue_section_fixture()
      update_attrs = %{name: "some updated name", venue_id: 43, display_order: 43, capacity: 43}

      assert {:ok, %VenueSection{} = venue_section} = Ticketing.update_venue_section(venue_section, update_attrs)
      assert venue_section.name == "some updated name"
      assert venue_section.venue_id == 43
      assert venue_section.display_order == 43
      assert venue_section.capacity == 43
    end

    test "update_venue_section/2 with invalid data returns error changeset" do
      venue_section = venue_section_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticketing.update_venue_section(venue_section, @invalid_attrs)
      assert venue_section == Ticketing.get_venue_section!(venue_section.id)
    end

    test "delete_venue_section/1 deletes the venue_section" do
      venue_section = venue_section_fixture()
      assert {:ok, %VenueSection{}} = Ticketing.delete_venue_section(venue_section)
      assert_raise Ecto.NoResultsError, fn -> Ticketing.get_venue_section!(venue_section.id) end
    end

    test "change_venue_section/1 returns a venue_section changeset" do
      venue_section = venue_section_fixture()
      assert %Ecto.Changeset{} = Ticketing.change_venue_section(venue_section)
    end
  end

  describe "season_subscriptions" do
    alias Symphony.Ticketing.SeasonSubscription

    import Symphony.TicketingFixtures

    @invalid_attrs %{active: nil, description: nil, slug: nil, display_name: nil, ensemble_id: nil, total_seats_per_holder: nil, base_price_cents: nil}

    test "list_season_subscriptions/0 returns all season_subscriptions" do
      season_subscription = season_subscription_fixture()
      assert Ticketing.list_season_subscriptions() == [season_subscription]
    end

    test "get_season_subscription!/1 returns the season_subscription with given id" do
      season_subscription = season_subscription_fixture()
      assert Ticketing.get_season_subscription!(season_subscription.id) == season_subscription
    end

    test "create_season_subscription/1 with valid data creates a season_subscription" do
      valid_attrs = %{active: true, description: "some description", slug: "some slug", display_name: "some display_name", ensemble_id: 42, total_seats_per_holder: 42, base_price_cents: 42}

      assert {:ok, %SeasonSubscription{} = season_subscription} = Ticketing.create_season_subscription(valid_attrs)
      assert season_subscription.active == true
      assert season_subscription.description == "some description"
      assert season_subscription.slug == "some slug"
      assert season_subscription.display_name == "some display_name"
      assert season_subscription.ensemble_id == 42
      assert season_subscription.total_seats_per_holder == 42
      assert season_subscription.base_price_cents == 42
    end

    test "create_season_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Ticketing.create_season_subscription(@invalid_attrs)
    end

    test "update_season_subscription/2 with valid data updates the season_subscription" do
      season_subscription = season_subscription_fixture()
      update_attrs = %{active: false, description: "some updated description", slug: "some updated slug", display_name: "some updated display_name", ensemble_id: 43, total_seats_per_holder: 43, base_price_cents: 43}

      assert {:ok, %SeasonSubscription{} = season_subscription} = Ticketing.update_season_subscription(season_subscription, update_attrs)
      assert season_subscription.active == false
      assert season_subscription.description == "some updated description"
      assert season_subscription.slug == "some updated slug"
      assert season_subscription.display_name == "some updated display_name"
      assert season_subscription.ensemble_id == 43
      assert season_subscription.total_seats_per_holder == 43
      assert season_subscription.base_price_cents == 43
    end

    test "update_season_subscription/2 with invalid data returns error changeset" do
      season_subscription = season_subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = Ticketing.update_season_subscription(season_subscription, @invalid_attrs)
      assert season_subscription == Ticketing.get_season_subscription!(season_subscription.id)
    end

    test "delete_season_subscription/1 deletes the season_subscription" do
      season_subscription = season_subscription_fixture()
      assert {:ok, %SeasonSubscription{}} = Ticketing.delete_season_subscription(season_subscription)
      assert_raise Ecto.NoResultsError, fn -> Ticketing.get_season_subscription!(season_subscription.id) end
    end

    test "change_season_subscription/1 returns a season_subscription changeset" do
      season_subscription = season_subscription_fixture()
      assert %Ecto.Changeset{} = Ticketing.change_season_subscription(season_subscription)
    end
  end
end
