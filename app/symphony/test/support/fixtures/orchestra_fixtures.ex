defmodule Symphony.OrchestraFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Symphony.Orchestra` context.
  """

  @doc """
  Generate a venue.
  """
  def venue_fixture(attrs \\ %{}) do
    {:ok, venue} =
      attrs
      |> Enum.into(%{
        address: "some address",
        name: "some name"
      })
      |> Symphony.Orchestra.create_venue()

    venue
  end

  @doc """
  Generate a ensemble.
  """
  def ensemble_fixture(attrs \\ %{}) do
    {:ok, ensemble} =
      attrs
      |> Enum.into(%{
        description: "some description",
        kind: "some kind",
        name: "some name"
      })
      |> Symphony.Orchestra.create_ensemble()

    ensemble
  end

  @doc """
  Generate a section.
  """
  def section_fixture(attrs \\ %{}) do
    {:ok, section} =
      attrs
      |> Enum.into(%{
        description: "some description",
        icon_url: "some icon_url",
        name: "some name",
        parent_section_id: 42
      })
      |> Symphony.Orchestra.create_section()

    section
  end
end
