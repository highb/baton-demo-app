defmodule SymphonyWeb.Api.AudienceMemberJSON do
  alias Symphony.Identity.AudienceMember

  @doc """
  Renders a list of audience_members.
  """
  def index(%{audience_members: audience_members}) do
    %{data: for(audience_member <- audience_members, do: data(audience_member))}
  end

  @doc """
  Renders a single audience_member.
  """
  def show(%{audience_member: audience_member}) do
    %{data: data(audience_member)}
  end

  defp data(%AudienceMember{} = audience_member) do
    %{
      id: audience_member.id,
      login: audience_member.login,
      primary_email: audience_member.primary_email,
      given_name: audience_member.given_name,
      family_name: audience_member.family_name,
      status: audience_member.status,
      loyalty_tier: audience_member.loyalty_tier,
      loyalty_points: audience_member.loyalty_points
    }
  end
end
