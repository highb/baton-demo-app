defmodule SymphonyWeb.Api.PermissionJSON do
  alias Symphony.Rbac.Permission

  @doc """
  Renders a list of permissions.
  """
  def index(%{permissions: permissions}) do
    %{data: for(permission <- permissions, do: data(permission))}
  end

  @doc """
  Renders a single permission.
  """
  def show(%{permission: permission}) do
    %{data: data(permission)}
  end

  defp data(%Permission{} = permission) do
    %{
      id: permission.id,
      slug: permission.slug,
      resource_kind: permission.resource_kind,
      description: permission.description
    }
  end
end
