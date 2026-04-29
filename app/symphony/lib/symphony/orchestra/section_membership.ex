defmodule Symphony.Orchestra.SectionMembership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Orchestra.Section

  @primary_key false
  schema "section_memberships" do
    belongs_to :section, Section, primary_key: true
    belongs_to :musician, Musician, primary_key: true
    field :is_principal, :boolean, default: false
    field :joined_at, :utc_datetime

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:section_id, :musician_id, :is_principal, :joined_at])
    |> validate_required([:section_id, :musician_id, :joined_at])
  end
end
