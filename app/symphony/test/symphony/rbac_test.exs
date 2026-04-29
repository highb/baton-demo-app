defmodule Symphony.RbacTest do
  use Symphony.DataCase

  alias Symphony.Rbac

  describe "roles" do
    alias Symphony.Rbac.Role

    import Symphony.RbacFixtures

    @invalid_attrs %{description: nil, slug: nil, display_name: nil}

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Rbac.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Rbac.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      valid_attrs = %{description: "some description", slug: "some slug", display_name: "some display_name"}

      assert {:ok, %Role{} = role} = Rbac.create_role(valid_attrs)
      assert role.description == "some description"
      assert role.slug == "some slug"
      assert role.display_name == "some display_name"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rbac.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", display_name: "some updated display_name"}

      assert {:ok, %Role{} = role} = Rbac.update_role(role, update_attrs)
      assert role.description == "some updated description"
      assert role.slug == "some updated slug"
      assert role.display_name == "some updated display_name"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Rbac.update_role(role, @invalid_attrs)
      assert role == Rbac.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Rbac.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Rbac.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Rbac.change_role(role)
    end
  end

  describe "permissions" do
    alias Symphony.Rbac.Permission

    import Symphony.RbacFixtures

    @invalid_attrs %{description: nil, slug: nil, resource_kind: nil}

    test "list_permissions/0 returns all permissions" do
      permission = permission_fixture()
      assert Rbac.list_permissions() == [permission]
    end

    test "get_permission!/1 returns the permission with given id" do
      permission = permission_fixture()
      assert Rbac.get_permission!(permission.id) == permission
    end

    test "create_permission/1 with valid data creates a permission" do
      valid_attrs = %{description: "some description", slug: "some slug", resource_kind: "some resource_kind"}

      assert {:ok, %Permission{} = permission} = Rbac.create_permission(valid_attrs)
      assert permission.description == "some description"
      assert permission.slug == "some slug"
      assert permission.resource_kind == "some resource_kind"
    end

    test "create_permission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rbac.create_permission(@invalid_attrs)
    end

    test "update_permission/2 with valid data updates the permission" do
      permission = permission_fixture()
      update_attrs = %{description: "some updated description", slug: "some updated slug", resource_kind: "some updated resource_kind"}

      assert {:ok, %Permission{} = permission} = Rbac.update_permission(permission, update_attrs)
      assert permission.description == "some updated description"
      assert permission.slug == "some updated slug"
      assert permission.resource_kind == "some updated resource_kind"
    end

    test "update_permission/2 with invalid data returns error changeset" do
      permission = permission_fixture()
      assert {:error, %Ecto.Changeset{}} = Rbac.update_permission(permission, @invalid_attrs)
      assert permission == Rbac.get_permission!(permission.id)
    end

    test "delete_permission/1 deletes the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{}} = Rbac.delete_permission(permission)
      assert_raise Ecto.NoResultsError, fn -> Rbac.get_permission!(permission.id) end
    end

    test "change_permission/1 returns a permission changeset" do
      permission = permission_fixture()
      assert %Ecto.Changeset{} = Rbac.change_permission(permission)
    end
  end

  describe "applications" do
    alias Symphony.Rbac.Application

    import Symphony.RbacFixtures

    @invalid_attrs %{slug: nil, display_name: nil, help_url: nil, icon_url: nil, logo_url: nil}

    test "list_applications/0 returns all applications" do
      application = application_fixture()
      assert Rbac.list_applications() == [application]
    end

    test "get_application!/1 returns the application with given id" do
      application = application_fixture()
      assert Rbac.get_application!(application.id) == application
    end

    test "create_application/1 with valid data creates a application" do
      valid_attrs = %{slug: "some slug", display_name: "some display_name", help_url: "some help_url", icon_url: "some icon_url", logo_url: "some logo_url"}

      assert {:ok, %Application{} = application} = Rbac.create_application(valid_attrs)
      assert application.slug == "some slug"
      assert application.display_name == "some display_name"
      assert application.help_url == "some help_url"
      assert application.icon_url == "some icon_url"
      assert application.logo_url == "some logo_url"
    end

    test "create_application/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rbac.create_application(@invalid_attrs)
    end

    test "update_application/2 with valid data updates the application" do
      application = application_fixture()
      update_attrs = %{slug: "some updated slug", display_name: "some updated display_name", help_url: "some updated help_url", icon_url: "some updated icon_url", logo_url: "some updated logo_url"}

      assert {:ok, %Application{} = application} = Rbac.update_application(application, update_attrs)
      assert application.slug == "some updated slug"
      assert application.display_name == "some updated display_name"
      assert application.help_url == "some updated help_url"
      assert application.icon_url == "some updated icon_url"
      assert application.logo_url == "some updated logo_url"
    end

    test "update_application/2 with invalid data returns error changeset" do
      application = application_fixture()
      assert {:error, %Ecto.Changeset{}} = Rbac.update_application(application, @invalid_attrs)
      assert application == Rbac.get_application!(application.id)
    end

    test "delete_application/1 deletes the application" do
      application = application_fixture()
      assert {:ok, %Application{}} = Rbac.delete_application(application)
      assert_raise Ecto.NoResultsError, fn -> Rbac.get_application!(application.id) end
    end

    test "change_application/1 returns a application changeset" do
      application = application_fixture()
      assert %Ecto.Changeset{} = Rbac.change_application(application)
    end
  end
end
