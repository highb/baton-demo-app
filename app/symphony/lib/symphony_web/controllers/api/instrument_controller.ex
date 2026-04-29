defmodule SymphonyWeb.Api.InstrumentController do
  use SymphonyWeb, :controller

  alias Symphony.Inventory
  alias Symphony.Inventory.Instrument

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    instruments = Inventory.list_instruments()
    render(conn, :index, instruments: instruments)
  end

  def create(conn, %{"instrument" => instrument_params}) do
    with {:ok, %Instrument{} = instrument} <- Inventory.create_instrument(instrument_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/instruments/#{instrument}")
      |> render(:show, instrument: instrument)
    end
  end

  def show(conn, %{"id" => id}) do
    instrument = Inventory.get_instrument!(id)
    render(conn, :show, instrument: instrument)
  end

  def update(conn, %{"id" => id, "instrument" => instrument_params}) do
    instrument = Inventory.get_instrument!(id)

    with {:ok, %Instrument{} = instrument} <- Inventory.update_instrument(instrument, instrument_params) do
      render(conn, :show, instrument: instrument)
    end
  end

  def delete(conn, %{"id" => id}) do
    instrument = Inventory.get_instrument!(id)

    with {:ok, %Instrument{}} <- Inventory.delete_instrument(instrument) do
      send_resp(conn, :no_content, "")
    end
  end
end
