defmodule Symphony.Rbac.ApplicationAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Rbac.Application

  @primary_key false
  schema "application_assignments" do
    belongs_to :application, Application, primary_key: true
    belongs_to :musician, Musician, primary_key: true
    field :granted_at, :utc_datetime

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:application_id, :musician_id, :granted_at])
    |> validate_required([:application_id, :musician_id, :granted_at])
  end
end
