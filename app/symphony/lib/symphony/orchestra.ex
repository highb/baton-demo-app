defmodule Symphony.Orchestra do
  @moduledoc """
  The Orchestra context.
  """

  import Ecto.Query, warn: false
  alias Symphony.Repo

  alias Symphony.Orchestra.{Venue, Ensemble, Section}

  # ---- Venues ----

  def list_venues do
    Repo.all(from v in Venue, order_by: [asc: v.name])
  end

  def get_venue!(id), do: Repo.get!(Venue, id)

  def create_venue(attrs) do
    %Venue{}
    |> Venue.changeset(attrs)
    |> Repo.insert()
  end

  def update_venue(%Venue{} = venue, attrs) do
    venue
    |> Venue.changeset(attrs)
    |> Repo.update()
  end

  def delete_venue(%Venue{} = venue), do: Repo.delete(venue)

  def change_venue(%Venue{} = venue, attrs \\ %{}) do
    Venue.changeset(venue, attrs)
  end

  # ---- Ensembles ----

  def list_ensembles do
    Repo.all(from e in Ensemble, order_by: [asc: e.name])
  end

  def get_ensemble!(id), do: Repo.get!(Ensemble, id)

  def create_ensemble(attrs) do
    %Ensemble{}
    |> Ensemble.changeset(attrs)
    |> Repo.insert()
  end

  def update_ensemble(%Ensemble{} = ensemble, attrs) do
    ensemble
    |> Ensemble.changeset(attrs)
    |> Repo.update()
  end

  def delete_ensemble(%Ensemble{} = ensemble), do: Repo.delete(ensemble)

  def change_ensemble(%Ensemble{} = ensemble, attrs \\ %{}) do
    Ensemble.changeset(ensemble, attrs)
  end

  # ---- Sections ----

  def list_sections do
    Repo.all(from s in Section, order_by: [asc: s.name])
  end

  def get_section!(id), do: Repo.get!(Section, id)

  def create_section(attrs) do
    %Section{}
    |> Section.changeset(attrs)
    |> Repo.insert()
  end

  def update_section(%Section{} = section, attrs) do
    section
    |> Section.changeset(attrs)
    |> Repo.update()
  end

  def delete_section(%Section{} = section), do: Repo.delete(section)

  def change_section(%Section{} = section, attrs \\ %{}) do
    Section.changeset(section, attrs)
  end
end
