defmodule SymphonyWeb.Api.PerformanceJSON do
  alias Symphony.Scheduling.Performance

  @doc """
  Renders a list of performances.
  """
  def index(%{performances: performances}) do
    %{data: for(performance <- performances, do: data(performance))}
  end

  @doc """
  Renders a single performance.
  """
  def show(%{performance: performance}) do
    %{data: data(performance)}
  end

  defp data(%Performance{} = performance) do
    %{
      id: performance.id,
      ensemble_id: performance.ensemble_id,
      venue_id: performance.venue_id,
      scheduled_at: performance.scheduled_at,
      kind: performance.kind
    }
  end
end
