defmodule Symphony.Orchestra.EnsembleMembership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Orchestra.Ensemble

  @primary_key false
  schema "ensemble_memberships" do
    belongs_to :ensemble, Ensemble, primary_key: true
    belongs_to :musician, Musician, primary_key: true
    field :chair_position, :integer

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:ensemble_id, :musician_id, :chair_position])
    |> validate_required([:ensemble_id, :musician_id])
  end
end
