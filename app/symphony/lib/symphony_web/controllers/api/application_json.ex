defmodule SymphonyWeb.Api.ApplicationJSON do
  alias Symphony.Rbac.Application

  @doc """
  Renders a list of applications.
  """
  def index(%{applications: applications}) do
    %{data: for(application <- applications, do: data(application))}
  end

  @doc """
  Renders a single application.
  """
  def show(%{application: application}) do
    %{data: data(application)}
  end

  defp data(%Application{} = application) do
    %{
      id: application.id,
      slug: application.slug,
      display_name: application.display_name,
      help_url: application.help_url
    }
  end
end
