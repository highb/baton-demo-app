defmodule Symphony.Orchestra.Section do
  use Ecto.Schema
  import Ecto.Changeset

  alias Symphony.Orchestra.SectionMembership

  schema "sections" do
    field :name, :string
    field :description, :string
    field :icon_url, :string
    field :profile, :map, default: %{}

    belongs_to :parent_section, __MODULE__, foreign_key: :parent_section_id
    has_many :children, __MODULE__, foreign_key: :parent_section_id
    has_many :memberships, SectionMembership

    timestamps(type: :utc_datetime)
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:name, :description, :parent_section_id, :icon_url, :profile])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
