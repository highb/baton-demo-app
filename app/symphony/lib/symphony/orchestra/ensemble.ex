defmodule Symphony.Orchestra.Ensemble do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Orchestra.EnsembleMembership

  @kinds ~w(full chamber pit quartet trio quintet)

  schema "ensembles" do
    field :name, :string
    field :kind, :string
    field :description, :string

    has_many :memberships, EnsembleMembership

    timestamps(type: :utc_datetime)
  end

  def changeset(ensemble, attrs) do
    ensemble
    |> cast(attrs, [:name, :kind, :description])
    |> validate_required([:name, :kind])
    |> validate_inclusion(:kind, @kinds)
    |> unique_constraint(:name)
  end
end
