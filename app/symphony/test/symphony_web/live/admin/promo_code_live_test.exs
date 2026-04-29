defmodule SymphonyWeb.Admin.PromoCodeLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.TicketingFixtures

  @create_attrs %{active: true, code: "some code", display_name: "some display_name", discount_kind: "some discount_kind", discount_value: 42, min_total_cents: 42, max_redemptions: 42, current_redemptions: 42, applies_to_performance_id: 42}
  @update_attrs %{active: false, code: "some updated code", display_name: "some updated display_name", discount_kind: "some updated discount_kind", discount_value: 43, min_total_cents: 43, max_redemptions: 43, current_redemptions: 43, applies_to_performance_id: 43}
  @invalid_attrs %{active: false, code: nil, display_name: nil, discount_kind: nil, discount_value: nil, min_total_cents: nil, max_redemptions: nil, current_redemptions: nil, applies_to_performance_id: nil}
  defp create_promo_code(_) do
    promo_code = promo_code_fixture()

    %{promo_code: promo_code}
  end

  describe "Index" do
    setup [:create_promo_code]

    test "lists all promo_codes", %{conn: conn, promo_code: promo_code} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/promo_codes")

      assert html =~ "Listing Promo codes"
      assert html =~ promo_code.code
    end

    test "saves new promo_code", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/promo_codes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Promo code")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/promo_codes/new")

      assert render(form_live) =~ "New Promo code"

      assert form_live
             |> form("#promo_code-form", promo_code: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#promo_code-form", promo_code: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/promo_codes")

      html = render(index_live)
      assert html =~ "Promo code created successfully"
      assert html =~ "some code"
    end

    test "updates promo_code in listing", %{conn: conn, promo_code: promo_code} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/promo_codes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#promo_codes-#{promo_code.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/promo_codes/#{promo_code}/edit")

      assert render(form_live) =~ "Edit Promo code"

      assert form_live
             |> form("#promo_code-form", promo_code: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#promo_code-form", promo_code: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/promo_codes")

      html = render(index_live)
      assert html =~ "Promo code updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes promo_code in listing", %{conn: conn, promo_code: promo_code} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/promo_codes")

      assert index_live |> element("#promo_codes-#{promo_code.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#promo_codes-#{promo_code.id}")
    end
  end

  describe "Show" do
    setup [:create_promo_code]

    test "displays promo_code", %{conn: conn, promo_code: promo_code} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/promo_codes/#{promo_code}")

      assert html =~ "Show Promo code"
      assert html =~ promo_code.code
    end

    test "updates promo_code and returns to show", %{conn: conn, promo_code: promo_code} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/promo_codes/#{promo_code}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/promo_codes/#{promo_code}/edit?return_to=show")

      assert render(form_live) =~ "Edit Promo code"

      assert form_live
             |> form("#promo_code-form", promo_code: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#promo_code-form", promo_code: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/promo_codes/#{promo_code}")

      html = render(show_live)
      assert html =~ "Promo code updated successfully"
      assert html =~ "some updated code"
    end
  end
end
