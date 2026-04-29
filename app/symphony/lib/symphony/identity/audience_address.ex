defmodule Symphony.Identity.AudienceAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.AudienceMember

  schema "audience_addresses" do
    field :label, :string
    field :line1, :string
    field :line2, :string
    field :city, :string
    field :region, :string
    field :postal_code, :string
    field :country, :string
    field :is_primary, :boolean, default: false

    belongs_to :audience_member, AudienceMember

    timestamps(type: :utc_datetime)
  end

  @castable ~w(audience_member_id label line1 line2 city region postal_code country is_primary)a

  def changeset(address, attrs) do
    address
    |> cast(attrs, @castable)
    |> validate_required([:audience_member_id, :label, :line1, :city, :country])
  end
end
