defmodule SymphonyWeb.Api.SheetMusicControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.InventoryFixtures
  alias Symphony.Inventory.SheetMusic

  @create_attrs %{
    title: "some title",
    composer: "some composer",
    catalog_number: "some catalog_number",
    copyright_status: "some copyright_status",
    storage_uri: "some storage_uri"
  }
  @update_attrs %{
    title: "some updated title",
    composer: "some updated composer",
    catalog_number: "some updated catalog_number",
    copyright_status: "some updated copyright_status",
    storage_uri: "some updated storage_uri"
  }
  @invalid_attrs %{title: nil, composer: nil, catalog_number: nil, copyright_status: nil, storage_uri: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all sheet_music", %{conn: conn} do
      conn = get(conn, ~p"/api/api/sheet_music")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create sheet_music" do
    test "renders sheet_music when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/sheet_music", sheet_music: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/sheet_music/#{id}")

      assert %{
               "id" => ^id,
               "catalog_number" => "some catalog_number",
               "composer" => "some composer",
               "copyright_status" => "some copyright_status",
               "storage_uri" => "some storage_uri",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/sheet_music", sheet_music: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update sheet_music" do
    setup [:create_sheet_music]

    test "renders sheet_music when data is valid", %{conn: conn, sheet_music: %SheetMusic{id: id} = sheet_music} do
      conn = put(conn, ~p"/api/api/sheet_music/#{sheet_music}", sheet_music: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/sheet_music/#{id}")

      assert %{
               "id" => ^id,
               "catalog_number" => "some updated catalog_number",
               "composer" => "some updated composer",
               "copyright_status" => "some updated copyright_status",
               "storage_uri" => "some updated storage_uri",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, sheet_music: sheet_music} do
      conn = put(conn, ~p"/api/api/sheet_music/#{sheet_music}", sheet_music: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete sheet_music" do
    setup [:create_sheet_music]

    test "deletes chosen sheet_music", %{conn: conn, sheet_music: sheet_music} do
      conn = delete(conn, ~p"/api/api/sheet_music/#{sheet_music}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/sheet_music/#{sheet_music}")
      end
    end
  end

  defp create_sheet_music(_) do
    sheet_music = sheet_music_fixture()

    %{sheet_music: sheet_music}
  end
end
