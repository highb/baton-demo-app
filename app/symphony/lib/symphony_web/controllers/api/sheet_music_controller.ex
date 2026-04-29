defmodule SymphonyWeb.Api.SheetMusicController do
  use SymphonyWeb, :controller

  alias Symphony.Inventory
  alias Symphony.Inventory.SheetMusic

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    sheet_music = Inventory.list_sheet_music()
    render(conn, :index, sheet_music: sheet_music)
  end

  def create(conn, %{"sheet_music" => sheet_music_params}) do
    with {:ok, %SheetMusic{} = sheet_music} <- Inventory.create_sheet_music(sheet_music_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/sheet_music/#{sheet_music}")
      |> render(:show, sheet_music: sheet_music)
    end
  end

  def show(conn, %{"id" => id}) do
    sheet_music = Inventory.get_sheet_music!(id)
    render(conn, :show, sheet_music: sheet_music)
  end

  def update(conn, %{"id" => id, "sheet_music" => sheet_music_params}) do
    sheet_music = Inventory.get_sheet_music!(id)

    with {:ok, %SheetMusic{} = sheet_music} <- Inventory.update_sheet_music(sheet_music, sheet_music_params) do
      render(conn, :show, sheet_music: sheet_music)
    end
  end

  def delete(conn, %{"id" => id}) do
    sheet_music = Inventory.get_sheet_music!(id)

    with {:ok, %SheetMusic{}} <- Inventory.delete_sheet_music(sheet_music) do
      send_resp(conn, :no_content, "")
    end
  end
end
