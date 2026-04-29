defmodule Symphony.Identity.MusicianEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician

  schema "musician_emails" do
    field :address, :string
    field :is_primary, :boolean, default: false

    belongs_to :musician, Musician

    timestamps(type: :utc_datetime)
  end

  def changeset(email, attrs) do
    email
    |> cast(attrs, [:musician_id, :address, :is_primary])
    |> validate_required([:musician_id, :address])
    |> unique_constraint([:musician_id, :address])
  end
end
