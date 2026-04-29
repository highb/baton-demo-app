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
end
