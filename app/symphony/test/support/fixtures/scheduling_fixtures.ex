defmodule Symphony.SchedulingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Symphony.Scheduling` context.
  """

  @doc """
  Generate a performance.
  """
  def performance_fixture(attrs \\ %{}) do
    {:ok, performance} =
      attrs
      |> Enum.into(%{
        ensemble_id: 42,
        kind: "some kind",
        scheduled_at: ~U[2026-04-28 21:24:00Z],
        venue_id: 42
      })
      |> Symphony.Scheduling.create_performance()

    performance
  end
end
