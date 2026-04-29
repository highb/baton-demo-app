defmodule SymphonyWeb.Admin.InstrumentLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.InventoryFixtures

  @create_attrs %{status: "some status", family: "some family", kind: "some kind", asset_tag: "some asset_tag", manufacturer: "some manufacturer", model: "some model", condition: "some condition"}
  @update_attrs %{status: "some updated status", family: "some updated family", kind: "some updated kind", asset_tag: "some updated asset_tag", manufacturer: "some updated manufacturer", model: "some updated model", condition: "some updated condition"}
  @invalid_attrs %{status: nil, family: nil, kind: nil, asset_tag: nil, manufacturer: nil, model: nil, condition: nil}
  defp create_instrument(_) do
    instrument = instrument_fixture()

    %{instrument: instrument}
  end

  describe "Index" do
    setup [:create_instrument]

    test "lists all instruments", %{conn: conn, instrument: instrument} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/instruments")

      assert html =~ "Listing Instruments"
      assert html =~ instrument.asset_tag
    end

    test "saves new instrument", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/instruments")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Instrument")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/instruments/new")

      assert render(form_live) =~ "New Instrument"

      assert form_live
             |> form("#instrument-form", instrument: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#instrument-form", instrument: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/instruments")

      html = render(index_live)
      assert html =~ "Instrument created successfully"
      assert html =~ "some asset_tag"
    end

    test "updates instrument in listing", %{conn: conn, instrument: instrument} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/instruments")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#instruments-#{instrument.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/instruments/#{instrument}/edit")

      assert render(form_live) =~ "Edit Instrument"

      assert form_live
             |> form("#instrument-form", instrument: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#instrument-form", instrument: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/instruments")

      html = render(index_live)
      assert html =~ "Instrument updated successfully"
      assert html =~ "some updated asset_tag"
    end

    test "deletes instrument in listing", %{conn: conn, instrument: instrument} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/instruments")

      assert index_live |> element("#instruments-#{instrument.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#instruments-#{instrument.id}")
    end
  end

  describe "Show" do
    setup [:create_instrument]

    test "displays instrument", %{conn: conn, instrument: instrument} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/instruments/#{instrument}")

      assert html =~ "Show Instrument"
      assert html =~ instrument.asset_tag
    end

    test "updates instrument and returns to show", %{conn: conn, instrument: instrument} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/instruments/#{instrument}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/instruments/#{instrument}/edit?return_to=show")

      assert render(form_live) =~ "Edit Instrument"

      assert form_live
             |> form("#instrument-form", instrument: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#instrument-form", instrument: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/instruments/#{instrument}")

      html = render(show_live)
      assert html =~ "Instrument updated successfully"
      assert html =~ "some updated asset_tag"
    end
  end
end
