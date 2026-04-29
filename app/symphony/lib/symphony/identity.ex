defmodule Symphony.Identity do
  @moduledoc """
  The Identity context.

  Two distinct USER-trait populations live here:

  - `Musician` — staff (players, conductors, librarians, box-office agents,
    service accounts).
  - `AudienceMember` — customers (subscribers, patrons, comp recipients).

  Their schemas, role catalogs, and lifecycles diverge enough that they're
  modelled as separate resource types — see docs/database-design.md §2.
  """

  import Ecto.Query, warn: false
  alias Symphony.Repo

  alias Symphony.Identity.{Musician, AudienceMember}

  # ---- Musicians ----

  @doc "Returns all musicians, optionally filtered by free-text search across login + names + email."
  def list_musicians(opts \\ []) do
    search = Keyword.get(opts, :search)
    status = Keyword.get(opts, :status)

    Musician
    |> apply_musician_search(search)
    |> apply_musician_status(status)
    |> order_by([m], asc: m.family_name, asc: m.given_name, asc: m.login)
    |> Repo.all()
  end

  defp apply_musician_search(query, nil), do: query
  defp apply_musician_search(query, ""), do: query

  defp apply_musician_search(query, term) do
    like = "%" <> term <> "%"

    from m in query,
      where:
        like(m.login, ^like) or like(m.primary_email, ^like) or
          like(m.given_name, ^like) or like(m.family_name, ^like) or
          like(m.employee_id, ^like)
  end

  defp apply_musician_status(query, nil), do: query
  defp apply_musician_status(query, ""), do: query
  defp apply_musician_status(query, status) when is_binary(status) do
    apply_musician_status(query, String.to_existing_atom(status))
  end

  defp apply_musician_status(query, status) when is_atom(status) do
    from m in query, where: m.status == ^status
  end

  def get_musician!(id), do: Repo.get!(Musician, id)

  def create_musician(attrs) do
    %Musician{}
    |> Musician.changeset(attrs)
    |> Repo.insert()
  end

  def update_musician(%Musician{} = musician, attrs) do
    musician
    |> Musician.changeset(attrs)
    |> Repo.update()
  end

  def delete_musician(%Musician{} = musician), do: Repo.delete(musician)

  def change_musician(%Musician{} = musician, attrs \\ %{}) do
    Musician.changeset(musician, attrs)
  end

  # ---- Audience members ----

  def list_audience_members(opts \\ []) do
    search = Keyword.get(opts, :search)
    status = Keyword.get(opts, :status)
    tier = Keyword.get(opts, :loyalty_tier)

    AudienceMember
    |> apply_audience_search(search)
    |> apply_audience_status(status)
    |> apply_audience_tier(tier)
    |> order_by([a], asc: a.family_name, asc: a.given_name, asc: a.login)
    |> Repo.all()
  end

  defp apply_audience_search(query, nil), do: query
  defp apply_audience_search(query, ""), do: query

  defp apply_audience_search(query, term) do
    like = "%" <> term <> "%"

    from a in query,
      where:
        like(a.login, ^like) or like(a.primary_email, ^like) or
          like(a.given_name, ^like) or like(a.family_name, ^like)
  end

  defp apply_audience_status(query, nil), do: query
  defp apply_audience_status(query, ""), do: query
  defp apply_audience_status(query, status) when is_binary(status) do
    apply_audience_status(query, String.to_existing_atom(status))
  end

  defp apply_audience_status(query, status) when is_atom(status) do
    from a in query, where: a.status == ^status
  end

  defp apply_audience_tier(query, nil), do: query
  defp apply_audience_tier(query, ""), do: query
  defp apply_audience_tier(query, tier) when is_binary(tier) do
    apply_audience_tier(query, String.to_existing_atom(tier))
  end

  defp apply_audience_tier(query, tier) when is_atom(tier) do
    from a in query, where: a.loyalty_tier == ^tier
  end

  def get_audience_member!(id), do: Repo.get!(AudienceMember, id)

  def create_audience_member(attrs) do
    %AudienceMember{}
    |> AudienceMember.changeset(attrs)
    |> Repo.insert()
  end

  def update_audience_member(%AudienceMember{} = member, attrs) do
    member
    |> AudienceMember.changeset(attrs)
    |> Repo.update()
  end

  def delete_audience_member(%AudienceMember{} = member), do: Repo.delete(member)

  def change_audience_member(%AudienceMember{} = member, attrs \\ %{}) do
    AudienceMember.changeset(member, attrs)
  end
end
