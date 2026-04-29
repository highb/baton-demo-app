defmodule Symphony.Repo.Migrations.CreateIdentity do
  use Ecto.Migration

  def change do
    create table(:musicians) do
      add :login, :string, null: false
      add :primary_email, :string, null: false
      add :given_name, :string
      add :family_name, :string
      add :middle_names, :string
      add :account_type, :string, null: false
      add :status, :string, null: false
      add :status_details, :string
      add :employee_id, :string
      add :mfa_enabled, :boolean, default: false, null: false
      add :sso_enabled, :boolean, default: false, null: false
      add :password_hash, :string
      add :password_force_change, :boolean, default: false, null: false
      add :profile, :map, default: %{}
      add :icon_url, :string
      add :last_login_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:musicians, [:login])

    create table(:musician_emails) do
      add :musician_id, references(:musicians, on_delete: :delete_all), null: false
      add :address, :string, null: false
      add :is_primary, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:musician_emails, [:musician_id, :address])

    create table(:musician_login_aliases, primary_key: false) do
      add :musician_id, references(:musicians, on_delete: :delete_all),
        primary_key: true, null: false
      add :alias, :string, primary_key: true, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create table(:audience_members) do
      add :login, :string, null: false
      add :primary_email, :string, null: false
      add :given_name, :string
      add :family_name, :string
      add :account_type, :string, null: false, default: "human"
      add :status, :string, null: false, default: "enabled"
      add :status_details, :string
      add :marketing_opt_in, :boolean, default: false, null: false
      add :loyalty_tier, :string
      add :loyalty_points, :integer, default: 0, null: false
      add :password_hash, :string
      add :password_force_change, :boolean, default: false, null: false
      add :sso_enabled, :boolean, default: false, null: false
      add :mfa_enabled, :boolean, default: false, null: false
      add :profile, :map, default: %{}
      add :last_login_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:audience_members, [:login])

    create table(:audience_emails) do
      add :audience_member_id, references(:audience_members, on_delete: :delete_all), null: false
      add :address, :string, null: false
      add :is_primary, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:audience_emails, [:audience_member_id, :address])

    create table(:audience_addresses) do
      add :audience_member_id, references(:audience_members, on_delete: :delete_all), null: false
      add :label, :string, null: false
      add :line1, :string, null: false
      add :line2, :string
      add :city, :string, null: false
      add :region, :string
      add :postal_code, :string
      add :country, :string, null: false
      add :is_primary, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
