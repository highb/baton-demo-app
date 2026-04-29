defmodule Symphony.Rbac do
  @moduledoc """
  The Rbac context.
  """

  import Ecto.Query, warn: false
  alias Symphony.Repo

  alias Symphony.Rbac.{Role, Permission, Application}

  # ---- Roles ----

  def list_roles do
    Repo.all(from r in Role, order_by: [asc: r.slug])
  end

  def get_role!(id), do: Repo.get!(Role, id)

  def create_role(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def delete_role(%Role{} = role), do: Repo.delete(role)

  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  # ---- Permissions ----

  def list_permissions do
    Repo.all(from p in Permission, order_by: [asc: p.slug])
  end

  def get_permission!(id), do: Repo.get!(Permission, id)

  def create_permission(attrs) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  def delete_permission(%Permission{} = permission), do: Repo.delete(permission)

  def change_permission(%Permission{} = permission, attrs \\ %{}) do
    Permission.changeset(permission, attrs)
  end

  # ---- Applications ----

  def list_applications do
    Repo.all(from a in Application, order_by: [asc: a.slug])
  end

  def get_application!(id), do: Repo.get!(Application, id)

  def create_application(attrs) do
    %Application{}
    |> Application.changeset(attrs)
    |> Repo.insert()
  end

  def update_application(%Application{} = application, attrs) do
    application
    |> Application.changeset(attrs)
    |> Repo.update()
  end

  def delete_application(%Application{} = application), do: Repo.delete(application)

  def change_application(%Application{} = application, attrs \\ %{}) do
    Application.changeset(application, attrs)
  end
end
