defmodule SymphonyWeb.Api.PriceTierJSON do
  alias Symphony.Ticketing.PriceTier

  @doc """
  Renders a list of price_tiers.
  """
  def index(%{price_tiers: price_tiers}) do
    %{data: for(price_tier <- price_tiers, do: data(price_tier))}
  end

  @doc """
  Renders a single price_tier.
  """
  def show(%{price_tier: price_tier}) do
    %{data: data(price_tier)}
  end

  defp data(%PriceTier{} = price_tier) do
    %{
      id: price_tier.id,
      slug: price_tier.slug,
      display_name: price_tier.display_name,
      is_comp: price_tier.is_comp
    }
  end
end
