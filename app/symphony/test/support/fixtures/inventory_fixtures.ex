defmodule Symphony.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Symphony.Inventory` context.
  """

  @doc """
  Generate a instrument.
  """
  def instrument_fixture(attrs \\ %{}) do
    {:ok, instrument} =
      attrs
      |> Enum.into(%{
        asset_tag: "some asset_tag",
        condition: "some condition",
        family: "some family",
        kind: "some kind",
        manufacturer: "some manufacturer",
        model: "some model",
        status: "some status"
      })
      |> Symphony.Inventory.create_instrument()

    instrument
  end

  @doc """
  Generate a equipment.
  """
  def equipment_fixture(attrs \\ %{}) do
    {:ok, equipment} =
      attrs
      |> Enum.into(%{
        asset_tag: "some asset_tag",
        category: "some category",
        description: "some description",
        status: "some status"
      })
      |> Symphony.Inventory.create_equipment()

    equipment
  end

  @doc """
  Generate a sheet_music.
  """
  def sheet_music_fixture(attrs \\ %{}) do
    {:ok, sheet_music} =
      attrs
      |> Enum.into(%{
        arranger: "some arranger",
        catalog_number: "some catalog_number",
        composer: "some composer",
        copyright_status: "some copyright_status",
        difficulty: "some difficulty",
        duration_seconds: 42,
        storage_uri: "some storage_uri",
        title: "some title"
      })
      |> Symphony.Inventory.create_sheet_music()

    sheet_music
  end
end
