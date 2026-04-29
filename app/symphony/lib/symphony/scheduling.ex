defmodule Symphony.Scheduling do
  @moduledoc """
  The Scheduling context.
  """

  import Ecto.Query, warn: false
  alias Symphony.Repo

  alias Symphony.Scheduling.Performance

  def list_performances do
    Repo.all(from p in Performance, order_by: [asc: p.scheduled_at])
  end

  def get_performance!(id), do: Repo.get!(Performance, id)

  def create_performance(attrs) do
    %Performance{}
    |> Performance.changeset(attrs)
    |> Repo.insert()
  end

  def update_performance(%Performance{} = performance, attrs) do
    performance
    |> Performance.changeset(attrs)
    |> Repo.update()
  end

  def delete_performance(%Performance{} = performance), do: Repo.delete(performance)

  def change_performance(%Performance{} = performance, attrs \\ %{}) do
    Performance.changeset(performance, attrs)
  end
end
