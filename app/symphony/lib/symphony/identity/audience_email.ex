defmodule Symphony.Identity.AudienceEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.AudienceMember

  schema "audience_emails" do
    field :address, :string
    field :is_primary, :boolean, default: false

    belongs_to :audience_member, AudienceMember

    timestamps(type: :utc_datetime)
  end

  def changeset(email, attrs) do
    email
    |> cast(attrs, [:audience_member_id, :address, :is_primary])
    |> validate_required([:audience_member_id, :address])
    |> unique_constraint([:audience_member_id, :address])
  end
end
