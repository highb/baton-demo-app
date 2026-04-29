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

  describe "equipment" do
    alias Symphony.Inventory.Equipment

    import Symphony.InventoryFixtures

    @invalid_attrs %{status: nil, description: nil, category: nil, asset_tag: nil}

    test "list_equipment/0 returns all equipment" do
      equipment = equipment_fixture()
      assert Inventory.list_equipment() == [equipment]
    end

    test "get_equipment!/1 returns the equipment with given id" do
      equipment = equipment_fixture()
      assert Inventory.get_equipment!(equipment.id) == equipment
    end

    test "create_equipment/1 with valid data creates a equipment" do
      valid_attrs = %{status: "some status", description: "some description", category: "some category", asset_tag: "some asset_tag"}

      assert {:ok, %Equipment{} = equipment} = Inventory.create_equipment(valid_attrs)
      assert equipment.status == "some status"
      assert equipment.description == "some description"
      assert equipment.category == "some category"
      assert equipment.asset_tag == "some asset_tag"
    end

    test "create_equipment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_equipment(@invalid_attrs)
    end

    test "update_equipment/2 with valid data updates the equipment" do
      equipment = equipment_fixture()
      update_attrs = %{status: "some updated status", description: "some updated description", category: "some updated category", asset_tag: "some updated asset_tag"}

      assert {:ok, %Equipment{} = equipment} = Inventory.update_equipment(equipment, update_attrs)
      assert equipment.status == "some updated status"
      assert equipment.description == "some updated description"
      assert equipment.category == "some updated category"
      assert equipment.asset_tag == "some updated asset_tag"
    end

    test "update_equipment/2 with invalid data returns error changeset" do
      equipment = equipment_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_equipment(equipment, @invalid_attrs)
      assert equipment == Inventory.get_equipment!(equipment.id)
    end

    test "delete_equipment/1 deletes the equipment" do
      equipment = equipment_fixture()
      assert {:ok, %Equipment{}} = Inventory.delete_equipment(equipment)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_equipment!(equipment.id) end
    end

    test "change_equipment/1 returns a equipment changeset" do
      equipment = equipment_fixture()
      assert %Ecto.Changeset{} = Inventory.change_equipment(equipment)
    end
  end

  describe "sheet_music" do
    alias Symphony.Inventory.SheetMusic

    import Symphony.InventoryFixtures

    @invalid_attrs %{title: nil, composer: nil, arranger: nil, catalog_number: nil, difficulty: nil, duration_seconds: nil, copyright_status: nil, storage_uri: nil}

    test "list_sheet_music/0 returns all sheet_music" do
      sheet_music = sheet_music_fixture()
      assert Inventory.list_sheet_music() == [sheet_music]
    end

    test "get_sheet_music!/1 returns the sheet_music with given id" do
      sheet_music = sheet_music_fixture()
      assert Inventory.get_sheet_music!(sheet_music.id) == sheet_music
    end

    test "create_sheet_music/1 with valid data creates a sheet_music" do
      valid_attrs = %{title: "some title", composer: "some composer", arranger: "some arranger", catalog_number: "some catalog_number", difficulty: "some difficulty", duration_seconds: 42, copyright_status: "some copyright_status", storage_uri: "some storage_uri"}

      assert {:ok, %SheetMusic{} = sheet_music} = Inventory.create_sheet_music(valid_attrs)
      assert sheet_music.title == "some title"
      assert sheet_music.composer == "some composer"
      assert sheet_music.arranger == "some arranger"
      assert sheet_music.catalog_number == "some catalog_number"
      assert sheet_music.difficulty == "some difficulty"
      assert sheet_music.duration_seconds == 42
      assert sheet_music.copyright_status == "some copyright_status"
      assert sheet_music.storage_uri == "some storage_uri"
    end

    test "create_sheet_music/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_sheet_music(@invalid_attrs)
    end

    test "update_sheet_music/2 with valid data updates the sheet_music" do
      sheet_music = sheet_music_fixture()
      update_attrs = %{title: "some updated title", composer: "some updated composer", arranger: "some updated arranger", catalog_number: "some updated catalog_number", difficulty: "some updated difficulty", duration_seconds: 43, copyright_status: "some updated copyright_status", storage_uri: "some updated storage_uri"}

      assert {:ok, %SheetMusic{} = sheet_music} = Inventory.update_sheet_music(sheet_music, update_attrs)
      assert sheet_music.title == "some updated title"
      assert sheet_music.composer == "some updated composer"
      assert sheet_music.arranger == "some updated arranger"
      assert sheet_music.catalog_number == "some updated catalog_number"
      assert sheet_music.difficulty == "some updated difficulty"
      assert sheet_music.duration_seconds == 43
      assert sheet_music.copyright_status == "some updated copyright_status"
      assert sheet_music.storage_uri == "some updated storage_uri"
    end

    test "update_sheet_music/2 with invalid data returns error changeset" do
      sheet_music = sheet_music_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_sheet_music(sheet_music, @invalid_attrs)
      assert sheet_music == Inventory.get_sheet_music!(sheet_music.id)
    end

    test "delete_sheet_music/1 deletes the sheet_music" do
      sheet_music = sheet_music_fixture()
      assert {:ok, %SheetMusic{}} = Inventory.delete_sheet_music(sheet_music)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_sheet_music!(sheet_music.id) end
    end

    test "change_sheet_music/1 returns a sheet_music changeset" do
      sheet_music = sheet_music_fixture()
      assert %Ecto.Changeset{} = Inventory.change_sheet_music(sheet_music)
    end
  end
end
