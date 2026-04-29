defmodule SymphonyWeb.Api.SectionJSON do
  alias Symphony.Orchestra.Section

  @doc """
  Renders a list of sections.
  """
  def index(%{sections: sections}) do
    %{data: for(section <- sections, do: data(section))}
  end

  @doc """
  Renders a single section.
  """
  def show(%{section: section}) do
    %{data: data(section)}
  end

  defp data(%Section{} = section) do
    %{
      id: section.id,
      name: section.name,
      description: section.description,
      parent_section_id: section.parent_section_id
    }
  end
end
