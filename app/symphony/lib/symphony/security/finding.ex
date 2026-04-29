defmodule Symphony.Security.Finding do
  use Ecto.Schema
  import Ecto.Changeset

  @severities ~w(low medium high critical)a

  schema "security_findings" do
    field :subject_resource_kind, :string
    field :subject_resource_id, :integer
    field :severity, Ecto.Enum, values: @severities
    field :finding_type, :string
    field :details, :map, default: %{}
    field :detected_at, :utc_datetime
    field :resolved_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @castable ~w(subject_resource_kind subject_resource_id severity finding_type
               details detected_at resolved_at)a

  def changeset(finding, attrs) do
    finding
    |> cast(attrs, @castable)
    |> validate_required([:subject_resource_kind, :subject_resource_id, :severity,
                          :finding_type, :detected_at])
  end
end
