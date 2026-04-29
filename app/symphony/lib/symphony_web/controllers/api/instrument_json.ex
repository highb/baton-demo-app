defmodule SymphonyWeb.Api.InstrumentJSON do
  alias Symphony.Inventory.Instrument

  @doc """
  Renders a list of instruments.
  """
  def index(%{instruments: instruments}) do
    %{data: for(instrument <- instruments, do: data(instrument))}
  end

  @doc """
  Renders a single instrument.
  """
  def show(%{instrument: instrument}) do
    %{data: data(instrument)}
  end

  defp data(%Instrument{} = instrument) do
    %{
      id: instrument.id,
      asset_tag: instrument.asset_tag,
      family: instrument.family,
      kind: instrument.kind,
      condition: instrument.condition,
      status: instrument.status
    }
  end
end
