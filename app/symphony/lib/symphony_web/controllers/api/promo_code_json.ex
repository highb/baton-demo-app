defmodule SymphonyWeb.Api.PromoCodeJSON do
  alias Symphony.Ticketing.PromoCode

  @doc """
  Renders a list of promo_codes.
  """
  def index(%{promo_codes: promo_codes}) do
    %{data: for(promo_code <- promo_codes, do: data(promo_code))}
  end

  @doc """
  Renders a single promo_code.
  """
  def show(%{promo_code: promo_code}) do
    %{data: data(promo_code)}
  end

  defp data(%PromoCode{} = promo_code) do
    %{
      id: promo_code.id,
      code: promo_code.code,
      display_name: promo_code.display_name,
      discount_kind: promo_code.discount_kind,
      discount_value: promo_code.discount_value,
      active: promo_code.active
    }
  end
end
