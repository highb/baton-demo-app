defmodule Symphony.Identity.Musician do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.{MusicianEmail, MusicianLoginAlias}

  @account_types ~w(human service system)a
  @statuses ~w(enabled disabled deleted)a

  schema "musicians" do
    field :login, :string
    field :primary_email, :string
    field :given_name, :string
    field :family_name, :string
    field :middle_names, :string
    field :account_type, Ecto.Enum, values: @account_types
    field :status, Ecto.Enum, values: @statuses
    field :status_details, :string
    field :employee_id, :string
    field :mfa_enabled, :boolean, default: false
    field :sso_enabled, :boolean, default: false
    field :password_hash, :string
    field :password_force_change, :boolean, default: false
    field :profile, :map, default: %{}
    field :icon_url, :string
    field :last_login_at, :utc_datetime

    has_many :emails, MusicianEmail
    has_many :login_aliases, MusicianLoginAlias

    timestamps(type: :utc_datetime)
  end

  @castable ~w(login primary_email given_name family_name middle_names account_type
               status status_details employee_id mfa_enabled sso_enabled password_hash
               password_force_change profile icon_url last_login_at)a

  def changeset(musician, attrs) do
    musician
    |> cast(attrs, @castable)
    |> validate_required([:login, :primary_email, :account_type, :status])
    |> unique_constraint(:login)
  end
end
