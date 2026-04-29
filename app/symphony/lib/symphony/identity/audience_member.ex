defmodule Symphony.Identity.AudienceMember do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.{AudienceEmail, AudienceAddress}

  @account_types ~w(human service system)a
  @statuses ~w(enabled disabled deleted)a
  @loyalty_tiers ~w(bronze silver gold platinum)a

  schema "audience_members" do
    field :login, :string
    field :primary_email, :string
    field :given_name, :string
    field :family_name, :string
    field :account_type, Ecto.Enum, values: @account_types, default: :human
    field :status, Ecto.Enum, values: @statuses, default: :enabled
    field :status_details, :string
    field :marketing_opt_in, :boolean, default: false
    field :loyalty_tier, Ecto.Enum, values: @loyalty_tiers
    field :loyalty_points, :integer, default: 0
    field :password_hash, :string
    field :password_force_change, :boolean, default: false
    field :sso_enabled, :boolean, default: false
    field :mfa_enabled, :boolean, default: false
    field :profile, :map, default: %{}
    field :last_login_at, :utc_datetime

    has_many :emails, AudienceEmail
    has_many :addresses, AudienceAddress

    timestamps(type: :utc_datetime)
  end

  @castable ~w(login primary_email given_name family_name account_type status
               status_details marketing_opt_in loyalty_tier loyalty_points
               password_hash password_force_change sso_enabled mfa_enabled
               profile last_login_at)a

  def changeset(member, attrs) do
    member
    |> cast(attrs, @castable)
    |> validate_required([:login, :primary_email, :account_type, :status])
    |> unique_constraint(:login)
  end
end
