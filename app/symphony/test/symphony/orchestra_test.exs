defmodule Symphony.OrchestraTest do
  use Symphony.DataCase

  alias Symphony.Orchestra

  describe "venues" do
    alias Symphony.Orchestra.Venue

    import Symphony.OrchestraFixtures

    @invalid_attrs %{name: nil, address: nil}

    test "list_venues/0 returns all venues" do
      venue = venue_fixture()
      assert Orchestra.list_venues() == [venue]
    end

    test "get_venue!/1 returns the venue with given id" do
      venue = venue_fixture()
      assert Orchestra.get_venue!(venue.id) == venue
    end

    test "create_venue/1 with valid data creates a venue" do
      valid_attrs = %{name: "some name", address: "some address"}

      assert {:ok, %Venue{} = venue} = Orchestra.create_venue(valid_attrs)
      assert venue.name == "some name"
      assert venue.address == "some address"
    end

    test "create_venue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orchestra.create_venue(@invalid_attrs)
    end

    test "update_venue/2 with valid data updates the venue" do
      venue = venue_fixture()
      update_attrs = %{name: "some updated name", address: "some updated address"}

      assert {:ok, %Venue{} = venue} = Orchestra.update_venue(venue, update_attrs)
      assert venue.name == "some updated name"
      assert venue.address == "some updated address"
    end

    test "update_venue/2 with invalid data returns error changeset" do
      venue = venue_fixture()
      assert {:error, %Ecto.Changeset{}} = Orchestra.update_venue(venue, @invalid_attrs)
      assert venue == Orchestra.get_venue!(venue.id)
    end

    test "delete_venue/1 deletes the venue" do
      venue = venue_fixture()
      assert {:ok, %Venue{}} = Orchestra.delete_venue(venue)
      assert_raise Ecto.NoResultsError, fn -> Orchestra.get_venue!(venue.id) end
    end

    test "change_venue/1 returns a venue changeset" do
      venue = venue_fixture()
      assert %Ecto.Changeset{} = Orchestra.change_venue(venue)
    end
  end

  describe "ensembles" do
    alias Symphony.Orchestra.Ensemble

    import Symphony.OrchestraFixtures

    @invalid_attrs %{name: nil, description: nil, kind: nil}

    test "list_ensembles/0 returns all ensembles" do
      ensemble = ensemble_fixture()
      assert Orchestra.list_ensembles() == [ensemble]
    end

    test "get_ensemble!/1 returns the ensemble with given id" do
      ensemble = ensemble_fixture()
      assert Orchestra.get_ensemble!(ensemble.id) == ensemble
    end

    test "create_ensemble/1 with valid data creates a ensemble" do
      valid_attrs = %{name: "some name", description: "some description", kind: "some kind"}

      assert {:ok, %Ensemble{} = ensemble} = Orchestra.create_ensemble(valid_attrs)
      assert ensemble.name == "some name"
      assert ensemble.description == "some description"
      assert ensemble.kind == "some kind"
    end

    test "create_ensemble/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orchestra.create_ensemble(@invalid_attrs)
    end

    test "update_ensemble/2 with valid data updates the ensemble" do
      ensemble = ensemble_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", kind: "some updated kind"}

      assert {:ok, %Ensemble{} = ensemble} = Orchestra.update_ensemble(ensemble, update_attrs)
      assert ensemble.name == "some updated name"
      assert ensemble.description == "some updated description"
      assert ensemble.kind == "some updated kind"
    end

    test "update_ensemble/2 with invalid data returns error changeset" do
      ensemble = ensemble_fixture()
      assert {:error, %Ecto.Changeset{}} = Orchestra.update_ensemble(ensemble, @invalid_attrs)
      assert ensemble == Orchestra.get_ensemble!(ensemble.id)
    end

    test "delete_ensemble/1 deletes the ensemble" do
      ensemble = ensemble_fixture()
      assert {:ok, %Ensemble{}} = Orchestra.delete_ensemble(ensemble)
      assert_raise Ecto.NoResultsError, fn -> Orchestra.get_ensemble!(ensemble.id) end
    end

    test "change_ensemble/1 returns a ensemble changeset" do
      ensemble = ensemble_fixture()
      assert %Ecto.Changeset{} = Orchestra.change_ensemble(ensemble)
    end
  end

  describe "sections" do
    alias Symphony.Orchestra.Section

    import Symphony.OrchestraFixtures

    @invalid_attrs %{name: nil, description: nil, parent_section_id: nil, icon_url: nil}

    test "list_sections/0 returns all sections" do
      section = section_fixture()
      assert Orchestra.list_sections() == [section]
    end

    test "get_section!/1 returns the section with given id" do
      section = section_fixture()
      assert Orchestra.get_section!(section.id) == section
    end

    test "create_section/1 with valid data creates a section" do
      valid_attrs = %{name: "some name", description: "some description", parent_section_id: 42, icon_url: "some icon_url"}

      assert {:ok, %Section{} = section} = Orchestra.create_section(valid_attrs)
      assert section.name == "some name"
      assert section.description == "some description"
      assert section.parent_section_id == 42
      assert section.icon_url == "some icon_url"
    end

    test "create_section/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orchestra.create_section(@invalid_attrs)
    end

    test "update_section/2 with valid data updates the section" do
      section = section_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", parent_section_id: 43, icon_url: "some updated icon_url"}

      assert {:ok, %Section{} = section} = Orchestra.update_section(section, update_attrs)
      assert section.name == "some updated name"
      assert section.description == "some updated description"
      assert section.parent_section_id == 43
      assert section.icon_url == "some updated icon_url"
    end

    test "update_section/2 with invalid data returns error changeset" do
      section = section_fixture()
      assert {:error, %Ecto.Changeset{}} = Orchestra.update_section(section, @invalid_attrs)
      assert section == Orchestra.get_section!(section.id)
    end

    test "delete_section/1 deletes the section" do
      section = section_fixture()
      assert {:ok, %Section{}} = Orchestra.delete_section(section)
      assert_raise Ecto.NoResultsError, fn -> Orchestra.get_section!(section.id) end
    end

    test "change_section/1 returns a section changeset" do
      section = section_fixture()
      assert %Ecto.Changeset{} = Orchestra.change_section(section)
    end
  end
end
