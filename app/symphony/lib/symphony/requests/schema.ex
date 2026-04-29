defmodule Symphony.Requests.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Requests.{CustomFieldDef, Request}

  schema "request_schemas" do
    field :slug, :string
    field :display_name, :string
    field :types, {:array, :map}, default: []
    field :statuses, {:array, :map}, default: []

    has_many :custom_fields, CustomFieldDef, foreign_key: :schema_id
    has_many :requests, Request, foreign_key: :schema_id

    timestamps(type: :utc_datetime)
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:slug, :display_name, :types, :statuses])
    |> validate_required([:slug, :display_name])
    |> unique_constraint(:slug)
  end
end
