defmodule Symphony.Requests.CustomFieldDef do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Requests.Schema, as: RequestSchema

  @field_kinds ~w(string string_list bool number timestamp pick_string
                  pick_multi_string pick_object pick_multi_object)a

  schema "request_custom_field_defs" do
    field :field_id, :string
    field :display_name, :string
    field :required, :boolean, default: false
    field :field_kind, Ecto.Enum, values: @field_kinds
    field :config, :map, default: %{}

    belongs_to :schema, RequestSchema, foreign_key: :schema_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(schema_id field_id display_name required field_kind config)a

  def changeset(field, attrs) do
    field
    |> cast(attrs, @castable)
    |> validate_required([:schema_id, :field_id, :display_name, :field_kind])
    |> unique_constraint([:schema_id, :field_id])
  end
end
