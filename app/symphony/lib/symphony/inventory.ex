defmodule Symphony.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Symphony.Repo

  alias Symphony.Inventory.Instrument

  @doc """
  Returns the list of instruments.

  ## Examples

      iex> list_instruments()
      [%Instrument{}, ...]

  """
  def list_instruments do
    Repo.all(from i in Instrument, order_by: [asc: i.asset_tag])
  end

  @doc """
  Gets a single instrument.

  Raises if the Instrument does not exist.

  ## Examples

      iex> get_instrument!(123)
      %Instrument{}

  """
  def get_instrument!(id), do: Repo.get!(Instrument, id)

  @doc """
  Creates a instrument.

  ## Examples

      iex> create_instrument(%{field: value})
      {:ok, %Instrument{}}

      iex> create_instrument(%{field: bad_value})
      {:error, ...}

  """
  def create_instrument(attrs) do
    %Instrument{}
    |> Instrument.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a instrument.

  ## Examples

      iex> update_instrument(instrument, %{field: new_value})
      {:ok, %Instrument{}}

      iex> update_instrument(instrument, %{field: bad_value})
      {:error, ...}

  """
  def update_instrument(%Instrument{} = instrument, attrs) do
    instrument
    |> Instrument.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Instrument.

  ## Examples

      iex> delete_instrument(instrument)
      {:ok, %Instrument{}}

      iex> delete_instrument(instrument)
      {:error, ...}

  """
  def delete_instrument(%Instrument{} = instrument) do
    Repo.delete(instrument)
  end

  @doc """
  Returns a data structure for tracking instrument changes.

  ## Examples

      iex> change_instrument(instrument)
      %Todo{...}

  """
  def change_instrument(%Instrument{} = instrument, attrs \\ %{}) do
    Instrument.changeset(instrument, attrs)
  end

  alias Symphony.Inventory.Equipment

  @doc """
  Returns the list of equipment.

  ## Examples

      iex> list_equipment()
      [%Equipment{}, ...]

  """
  def list_equipment do
    Repo.all(from e in Equipment, order_by: [asc: e.asset_tag])
  end

  @doc """
  Gets a single equipment.

  Raises if the Equipment does not exist.

  ## Examples

      iex> get_equipment!(123)
      %Equipment{}

  """
  def get_equipment!(id), do: Repo.get!(Equipment, id)

  @doc """
  Creates a equipment.

  ## Examples

      iex> create_equipment(%{field: value})
      {:ok, %Equipment{}}

      iex> create_equipment(%{field: bad_value})
      {:error, ...}

  """
  def create_equipment(attrs) do
    %Equipment{}
    |> Equipment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a equipment.

  ## Examples

      iex> update_equipment(equipment, %{field: new_value})
      {:ok, %Equipment{}}

      iex> update_equipment(equipment, %{field: bad_value})
      {:error, ...}

  """
  def update_equipment(%Equipment{} = equipment, attrs) do
    equipment
    |> Equipment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Equipment.

  ## Examples

      iex> delete_equipment(equipment)
      {:ok, %Equipment{}}

      iex> delete_equipment(equipment)
      {:error, ...}

  """
  def delete_equipment(%Equipment{} = equipment) do
    Repo.delete(equipment)
  end

  @doc """
  Returns a data structure for tracking equipment changes.

  ## Examples

      iex> change_equipment(equipment)
      %Todo{...}

  """
  def change_equipment(%Equipment{} = equipment, attrs \\ %{}) do
    Equipment.changeset(equipment, attrs)
  end

  alias Symphony.Inventory.SheetMusic

  @doc """
  Returns the list of sheet_music.

  ## Examples

      iex> list_sheet_music()
      [%SheetMusic{}, ...]

  """
  def list_sheet_music do
    Repo.all(from s in SheetMusic, order_by: [asc: s.composer, asc: s.title])
  end

  @doc """
  Gets a single sheet_music.

  Raises if the Sheet music does not exist.

  ## Examples

      iex> get_sheet_music!(123)
      %SheetMusic{}

  """
  def get_sheet_music!(id), do: Repo.get!(SheetMusic, id)

  @doc """
  Creates a sheet_music.

  ## Examples

      iex> create_sheet_music(%{field: value})
      {:ok, %SheetMusic{}}

      iex> create_sheet_music(%{field: bad_value})
      {:error, ...}

  """
  def create_sheet_music(attrs) do
    %SheetMusic{}
    |> SheetMusic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sheet_music.

  ## Examples

      iex> update_sheet_music(sheet_music, %{field: new_value})
      {:ok, %SheetMusic{}}

      iex> update_sheet_music(sheet_music, %{field: bad_value})
      {:error, ...}

  """
  def update_sheet_music(%SheetMusic{} = sheet_music, attrs) do
    sheet_music
    |> SheetMusic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SheetMusic.

  ## Examples

      iex> delete_sheet_music(sheet_music)
      {:ok, %SheetMusic{}}

      iex> delete_sheet_music(sheet_music)
      {:error, ...}

  """
  def delete_sheet_music(%SheetMusic{} = sheet_music) do
    Repo.delete(sheet_music)
  end

  @doc """
  Returns a data structure for tracking sheet_music changes.

  ## Examples

      iex> change_sheet_music(sheet_music)
      %Todo{...}

  """
  def change_sheet_music(%SheetMusic{} = sheet_music, attrs \\ %{}) do
    SheetMusic.changeset(sheet_music, attrs)
  end
end
