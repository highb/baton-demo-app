defmodule SymphonyWeb.Api.EnsembleJSON do
  alias Symphony.Orchestra.Ensemble

  @doc """
  Renders a list of ensembles.
  """
  def index(%{ensembles: ensembles}) do
    %{data: for(ensemble <- ensembles, do: data(ensemble))}
  end

  @doc """
  Renders a single ensemble.
  """
  def show(%{ensemble: ensemble}) do
    %{data: data(ensemble)}
  end

  defp data(%Ensemble{} = ensemble) do
    %{
      id: ensemble.id,
      name: ensemble.name,
      kind: ensemble.kind,
      description: ensemble.description
    }
  end
end
