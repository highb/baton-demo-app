defmodule Symphony.RbacFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Symphony.Rbac` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        description: "some description",
        display_name: "some display_name",
        slug: "some slug"
      })
      |> Symphony.Rbac.create_role()

    role
  end

  @doc """
  Generate a permission.
  """
  def permission_fixture(attrs \\ %{}) do
    {:ok, permission} =
      attrs
      |> Enum.into(%{
        description: "some description",
        resource_kind: "some resource_kind",
        slug: "some slug"
      })
      |> Symphony.Rbac.create_permission()

    permission
  end

  @doc """
  Generate a application.
  """
  def application_fixture(attrs \\ %{}) do
    {:ok, application} =
      attrs
      |> Enum.into(%{
        display_name: "some display_name",
        help_url: "some help_url",
        icon_url: "some icon_url",
        logo_url: "some logo_url",
        slug: "some slug"
      })
      |> Symphony.Rbac.create_application()

    application
  end
end
