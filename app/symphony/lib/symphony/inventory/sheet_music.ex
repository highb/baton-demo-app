defmodule Symphony.Inventory.SheetMusic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Inventory.SheetMusicPart

  @copyright_statuses ~w(public_domain licensed restricted)a

  schema "sheet_music" do
    field :title, :string
    field :composer, :string
    field :arranger, :string
    field :catalog_number, :string
    field :difficulty, :string
    field :duration_seconds, :integer
    field :copyright_status, Ecto.Enum, values: @copyright_statuses
    field :storage_uri, :string

    has_many :parts, SheetMusicPart

    timestamps(type: :utc_datetime)
  end

  @castable ~w(title composer arranger catalog_number difficulty duration_seconds
               copyright_status storage_uri)a

  def changeset(sheet, attrs) do
    sheet
    |> cast(attrs, @castable)
    |> validate_required([:title, :composer, :copyright_status, :storage_uri])
    |> unique_constraint(:catalog_number)
  end
end
