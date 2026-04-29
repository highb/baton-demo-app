defmodule Symphony.SchedulingTest do
  use Symphony.DataCase

  alias Symphony.Scheduling

  describe "performances" do
    alias Symphony.Scheduling.Performance

    import Symphony.SchedulingFixtures

    @invalid_attrs %{kind: nil, ensemble_id: nil, venue_id: nil, scheduled_at: nil}

    test "list_performances/0 returns all performances" do
      performance = performance_fixture()
      assert Scheduling.list_performances() == [performance]
    end

    test "get_performance!/1 returns the performance with given id" do
      performance = performance_fixture()
      assert Scheduling.get_performance!(performance.id) == performance
    end

    test "create_performance/1 with valid data creates a performance" do
      valid_attrs = %{kind: "some kind", ensemble_id: 42, venue_id: 42, scheduled_at: ~U[2026-04-28 21:24:00Z]}

      assert {:ok, %Performance{} = performance} = Scheduling.create_performance(valid_attrs)
      assert performance.kind == "some kind"
      assert performance.ensemble_id == 42
      assert performance.venue_id == 42
      assert performance.scheduled_at == ~U[2026-04-28 21:24:00Z]
    end

    test "create_performance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduling.create_performance(@invalid_attrs)
    end

    test "update_performance/2 with valid data updates the performance" do
      performance = performance_fixture()
      update_attrs = %{kind: "some updated kind", ensemble_id: 43, venue_id: 43, scheduled_at: ~U[2026-04-29 21:24:00Z]}

      assert {:ok, %Performance{} = performance} = Scheduling.update_performance(performance, update_attrs)
      assert performance.kind == "some updated kind"
      assert performance.ensemble_id == 43
      assert performance.venue_id == 43
      assert performance.scheduled_at == ~U[2026-04-29 21:24:00Z]
    end

    test "update_performance/2 with invalid data returns error changeset" do
      performance = performance_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduling.update_performance(performance, @invalid_attrs)
      assert performance == Scheduling.get_performance!(performance.id)
    end

    test "delete_performance/1 deletes the performance" do
      performance = performance_fixture()
      assert {:ok, %Performance{}} = Scheduling.delete_performance(performance)
      assert_raise Ecto.NoResultsError, fn -> Scheduling.get_performance!(performance.id) end
    end

    test "change_performance/1 returns a performance changeset" do
      performance = performance_fixture()
      assert %Ecto.Changeset{} = Scheduling.change_performance(performance)
    end
  end
end
