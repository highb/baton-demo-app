defmodule SymphonyWeb.Api.SheetMusicJSON do
  alias Symphony.Inventory.SheetMusic

  @doc """
  Renders a list of sheet_music.
  """
  def index(%{sheet_music: sheet_music}) do
    %{data: for(sheet_music <- sheet_music, do: data(sheet_music))}
  end

  @doc """
  Renders a single sheet_music.
  """
  def show(%{sheet_music: sheet_music}) do
    %{data: data(sheet_music)}
  end

  defp data(%SheetMusic{} = sheet_music) do
    %{
      id: sheet_music.id,
      title: sheet_music.title,
      composer: sheet_music.composer,
      catalog_number: sheet_music.catalog_number,
      copyright_status: sheet_music.copyright_status,
      storage_uri: sheet_music.storage_uri
    }
  end
end
