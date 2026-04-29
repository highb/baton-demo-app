defmodule SymphonyWeb.Api.EnsembleControllerTest do
  use SymphonyWeb.ConnCase

  import Symphony.OrchestraFixtures
  alias Symphony.Orchestra.Ensemble

  @create_attrs %{
    name: "some name",
    description: "some description",
    kind: "some kind"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    kind: "some updated kind"
  }
  @invalid_attrs %{name: nil, description: nil, kind: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all ensembles", %{conn: conn} do
      conn = get(conn, ~p"/api/api/ensembles")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create ensemble" do
    test "renders ensemble when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/ensembles", ensemble: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/api/ensembles/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "kind" => "some kind",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/api/ensembles", ensemble: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update ensemble" do
    setup [:create_ensemble]

    test "renders ensemble when data is valid", %{conn: conn, ensemble: %Ensemble{id: id} = ensemble} do
      conn = put(conn, ~p"/api/api/ensembles/#{ensemble}", ensemble: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/api/ensembles/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "kind" => "some updated kind",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, ensemble: ensemble} do
      conn = put(conn, ~p"/api/api/ensembles/#{ensemble}", ensemble: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete ensemble" do
    setup [:create_ensemble]

    test "deletes chosen ensemble", %{conn: conn, ensemble: ensemble} do
      conn = delete(conn, ~p"/api/api/ensembles/#{ensemble}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/api/ensembles/#{ensemble}")
      end
    end
  end

  defp create_ensemble(_) do
    ensemble = ensemble_fixture()

    %{ensemble: ensemble}
  end
end
