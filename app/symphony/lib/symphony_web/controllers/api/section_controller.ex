defmodule SymphonyWeb.Api.SectionController do
  use SymphonyWeb, :controller

  alias Symphony.Orchestra
  alias Symphony.Orchestra.Section

  action_fallback SymphonyWeb.FallbackController

  def index(conn, _params) do
    sections = Orchestra.list_sections()
    render(conn, :index, sections: sections)
  end

  def create(conn, %{"section" => section_params}) do
    with {:ok, %Section{} = section} <- Orchestra.create_section(section_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/sections/#{section}")
      |> render(:show, section: section)
    end
  end

  def show(conn, %{"id" => id}) do
    section = Orchestra.get_section!(id)
    render(conn, :show, section: section)
  end

  def update(conn, %{"id" => id, "section" => section_params}) do
    section = Orchestra.get_section!(id)

    with {:ok, %Section{} = section} <- Orchestra.update_section(section, section_params) do
      render(conn, :show, section: section)
    end
  end

  def delete(conn, %{"id" => id}) do
    section = Orchestra.get_section!(id)

    with {:ok, %Section{}} <- Orchestra.delete_section(section) do
      send_resp(conn, :no_content, "")
    end
  end
end
