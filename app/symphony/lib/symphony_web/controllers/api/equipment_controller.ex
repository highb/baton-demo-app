defmodule SymphonyWeb.Api.EquipmentController do
  use SymphonyWeb, :controller

  alias Symphony.Inventory
  alias Symphony.Inventory.Equipment

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    equipment = Inventory.list_equipment()
    render(conn, :index, equipment: equipment)
  end

  def create(conn, %{"equipment" => equipment_params}) do
    with {:ok, %Equipment{} = equipment} <- Inventory.create_equipment(equipment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/equipment/#{equipment}")
      |> render(:show, equipment: equipment)
    end
  end

  def show(conn, %{"id" => id}) do
    equipment = Inventory.get_equipment!(id)
    render(conn, :show, equipment: equipment)
  end

  def update(conn, %{"id" => id, "equipment" => equipment_params}) do
    equipment = Inventory.get_equipment!(id)

    with {:ok, %Equipment{} = equipment} <- Inventory.update_equipment(equipment, equipment_params) do
      render(conn, :show, equipment: equipment)
    end
  end

  def delete(conn, %{"id" => id}) do
    equipment = Inventory.get_equipment!(id)

    with {:ok, %Equipment{}} <- Inventory.delete_equipment(equipment) do
      send_resp(conn, :no_content, "")
    end
  end
end
