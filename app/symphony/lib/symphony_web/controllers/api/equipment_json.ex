defmodule SymphonyWeb.Api.EquipmentJSON do
  alias Symphony.Inventory.Equipment

  @doc """
  Renders a list of equipment.
  """
  def index(%{equipment: equipment}) do
    %{data: for(equipment <- equipment, do: data(equipment))}
  end

  @doc """
  Renders a single equipment.
  """
  def show(%{equipment: equipment}) do
    %{data: data(equipment)}
  end

  defp data(%Equipment{} = equipment) do
    %{
      id: equipment.id,
      asset_tag: equipment.asset_tag,
      category: equipment.category,
      status: equipment.status
    }
  end
end
