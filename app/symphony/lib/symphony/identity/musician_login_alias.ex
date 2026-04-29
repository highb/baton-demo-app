defmodule Symphony.Identity.MusicianLoginAlias do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician

  @primary_key false
  schema "musician_login_aliases" do
    belongs_to :musician, Musician, primary_key: true
    field :alias, :string, primary_key: true

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(login_alias, attrs) do
    login_alias
    |> cast(attrs, [:musician_id, :alias])
    |> validate_required([:musician_id, :alias])
  end
end
