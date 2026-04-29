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
end
