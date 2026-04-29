defmodule Symphony.InventoryTest do
  use Symphony.DataCase

  alias Symphony.Inventory

  describe "instruments" do
    alias Symphony.Inventory.Instrument

    import Symphony.InventoryFixtures

    @invalid_attrs %{status: nil, family: nil, kind: nil, asset_tag: nil, manufacturer: nil, model: nil, condition: nil}

    test "list_instruments/0 returns all instruments" do
      instrument = instrument_fixture()
      assert Inventory.list_instruments() == [instrument]
    end

    test "get_instrument!/1 returns the instrument with given id" do
      instrument = instrument_fixture()
      assert Inventory.get_instrument!(instrument.id) == instrument
    end

    test "create_instrument/1 with valid data creates a instrument" do
      valid_attrs = %{status: "some status", family: "some family", kind: "some kind", asset_tag: "some asset_tag", manufacturer: "some manufacturer", model: "some model", condition: "some condition"}

      assert {:ok, %Instrument{} = instrument} = Inventory.create_instrument(valid_attrs)
      assert instrument.status == "some status"
      assert instrument.family == "some family"
      assert instrument.kind == "some kind"
      assert instrument.asset_tag == "some asset_tag"
      assert instrument.manufacturer == "some manufacturer"
      assert instrument.model == "some model"
      assert instrument.condition == "some condition"
    end

    test "create_instrument/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_instrument(@invalid_attrs)
    end

    test "update_instrument/2 with valid data updates the instrument" do
      instrument = instrument_fixture()
      update_attrs = %{status: "some updated status", family: "some updated family", kind: "some updated kind", asset_tag: "some updated asset_tag", manufacturer: "some updated manufacturer", model: "some updated model", condition: "some updated condition"}

      assert {:ok, %Instrument{} = instrument} = Inventory.update_instrument(instrument, update_attrs)
      assert instrument.status == "some updated status"
      assert instrument.family == "some updated family"
      assert instrument.kind == "some updated kind"
      assert instrument.asset_tag == "some updated asset_tag"
      assert instrument.manufacturer == "some updated manufacturer"
      assert instrument.model == "some updated model"
      assert instrument.condition == "some updated condition"
    end

    test "update_instrument/2 with invalid data returns error changeset" do
      instrument = instrument_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_instrument(instrument, @invalid_attrs)
      assert instrument == Inventory.get_instrument!(instrument.id)
    end

    test "delete_instrument/1 deletes the instrument" do
      instrument = instrument_fixture()
      assert {:ok, %Instrument{}} = Inventory.delete_instrument(instrument)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_instrument!(instrument.id) end
    end

    test "change_instrument/1 returns a instrument changeset" do
      instrument = instrument_fixture()
      assert %Ecto.Changeset{} = Inventory.change_instrument(instrument)
    end
  end
end
