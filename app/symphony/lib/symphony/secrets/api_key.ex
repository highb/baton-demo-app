defmodule Symphony.Secrets.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician

  schema "api_keys" do
    field :name, :string
    field :hashed_secret, :string
    field :expires_at, :utc_datetime
    field :last_used_at, :utc_datetime
    field :profile, :map, default: %{}

    belongs_to :identity, Musician, foreign_key: :identity_id
    belongs_to :created_by, Musician, foreign_key: :created_by_id
    belongs_to :rotated_from, __MODULE__, foreign_key: :rotated_from_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(name identity_id created_by_id expires_at last_used_at hashed_secret
               rotated_from_id profile)a

  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, @castable)
    |> validate_required([:name, :identity_id, :hashed_secret])
  end
end
