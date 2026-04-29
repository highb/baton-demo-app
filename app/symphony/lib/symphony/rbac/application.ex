defmodule Symphony.Rbac.Application do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_flags ~w(hidden inactive saml oidc bookmark)

  schema "applications" do
    field :slug, :string
    field :display_name, :string
    field :help_url, :string
    field :flags, {:array, :string}, default: []
    field :icon_url, :string
    field :logo_url, :string
    field :profile, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  @castable ~w(slug display_name help_url flags icon_url logo_url profile)a

  def changeset(app, attrs) do
    app
    |> cast(attrs, @castable)
    |> validate_required([:slug, :display_name])
    |> validate_subset(:flags, @valid_flags)
    |> unique_constraint(:slug)
  end
end
