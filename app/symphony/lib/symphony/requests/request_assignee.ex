defmodule Symphony.Requests.RequestAssignee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Identity.Musician
  alias Symphony.Requests.Request

  @primary_key false
  schema "request_assignees" do
    belongs_to :request, Request, primary_key: true
    belongs_to :musician, Musician, primary_key: true

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(ra, attrs) do
    ra
    |> cast(attrs, [:request_id, :musician_id])
    |> validate_required([:request_id, :musician_id])
  end
end
