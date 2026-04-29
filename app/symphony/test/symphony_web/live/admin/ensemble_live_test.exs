defmodule SymphonyWeb.Admin.EnsembleLiveTest do
  use SymphonyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Symphony.OrchestraFixtures

  @create_attrs %{name: "some name", description: "some description", kind: "some kind"}
  @update_attrs %{name: "some updated name", description: "some updated description", kind: "some updated kind"}
  @invalid_attrs %{name: nil, description: nil, kind: nil}
  defp create_ensemble(_) do
    ensemble = ensemble_fixture()

    %{ensemble: ensemble}
  end

  describe "Index" do
    setup [:create_ensemble]

    test "lists all ensembles", %{conn: conn, ensemble: ensemble} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/ensembles")

      assert html =~ "Listing Ensembles"
      assert html =~ ensemble.name
    end

    test "saves new ensemble", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/ensembles")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Ensemble")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/ensembles/new")

      assert render(form_live) =~ "New Ensemble"

      assert form_live
             |> form("#ensemble-form", ensemble: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#ensemble-form", ensemble: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/ensembles")

      html = render(index_live)
      assert html =~ "Ensemble created successfully"
      assert html =~ "some name"
    end

    test "updates ensemble in listing", %{conn: conn, ensemble: ensemble} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/ensembles")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#ensembles-#{ensemble.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/ensembles/#{ensemble}/edit")

      assert render(form_live) =~ "Edit Ensemble"

      assert form_live
             |> form("#ensemble-form", ensemble: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#ensemble-form", ensemble: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/ensembles")

      html = render(index_live)
      assert html =~ "Ensemble updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes ensemble in listing", %{conn: conn, ensemble: ensemble} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/ensembles")

      assert index_live |> element("#ensembles-#{ensemble.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#ensembles-#{ensemble.id}")
    end
  end

  describe "Show" do
    setup [:create_ensemble]

    test "displays ensemble", %{conn: conn, ensemble: ensemble} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/ensembles/#{ensemble}")

      assert html =~ "Show Ensemble"
      assert html =~ ensemble.name
    end

    test "updates ensemble and returns to show", %{conn: conn, ensemble: ensemble} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/ensembles/#{ensemble}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/ensembles/#{ensemble}/edit?return_to=show")

      assert render(form_live) =~ "Edit Ensemble"

      assert form_live
             |> form("#ensemble-form", ensemble: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#ensemble-form", ensemble: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/ensembles/#{ensemble}")

      html = render(show_live)
      assert html =~ "Ensemble updated successfully"
      assert html =~ "some updated name"
    end
  end
end
