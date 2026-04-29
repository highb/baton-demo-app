defmodule SymphonyWeb.Api.MusicianJSON do
  alias Symphony.Identity.Musician

  @doc """
  Renders a list of musicians.
  """
  def index(%{musicians: musicians}) do
    %{data: for(musician <- musicians, do: data(musician))}
  end

  @doc """
  Renders a single musician.
  """
  def show(%{musician: musician}) do
    %{data: data(musician)}
  end

  defp data(%Musician{} = musician) do
    %{
      id: musician.id,
      login: musician.login,
      primary_email: musician.primary_email,
      given_name: musician.given_name,
      family_name: musician.family_name,
      account_type: musician.account_type,
      status: musician.status,
      employee_id: musician.employee_id
    }
  end
end
