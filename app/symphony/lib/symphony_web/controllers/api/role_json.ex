defmodule SymphonyWeb.Api.RoleJSON do
  alias Symphony.Rbac.Role

  @doc """
  Renders a list of roles.
  """
  def index(%{roles: roles}) do
    %{data: for(role <- roles, do: data(role))}
  end

  @doc """
  Renders a single role.
  """
  def show(%{role: role}) do
    %{data: data(role)}
  end

  defp data(%Role{} = role) do
    %{
      id: role.id,
      slug: role.slug,
      display_name: role.display_name,
      description: role.description
    }
  end
end
