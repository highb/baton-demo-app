defmodule Symphony.Requests.Request do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Requests.{Schema, RequestAssignee}

  schema "requests" do
    field :type_id, :string
    field :status_id, :string
    field :display_name, :string
    field :description, :string
    field :url, :string
    field :labels, {:array, :string}, default: []
    field :custom_fields, :map, default: %{}
    field :completed_at, :utc_datetime

    belongs_to :schema, Schema, foreign_key: :schema_id
    belongs_to :reporter, Musician, foreign_key: :reporter_id
    belongs_to :requested_for, Musician, foreign_key: :requested_for_id
    has_many :assignees, RequestAssignee, foreign_key: :request_id

    timestamps(type: :utc_datetime)
  end

  @castable ~w(schema_id type_id status_id display_name description reporter_id
               requested_for_id url labels custom_fields completed_at)a

  def changeset(request, attrs) do
    request
    |> cast(attrs, @castable)
    |> validate_required([:schema_id, :type_id, :status_id, :display_name, :reporter_id])
  end
end
