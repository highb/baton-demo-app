defmodule Symphony.EventFeed do
  @moduledoc """
  Cursor-paginated event-feed wrapper around `audit_events`.

  Cursor is just the last-seen `id` Base64url-encoded — the table is
  append-only and `id` is monotonic for any sane writer, so id-ordering
  is equivalent to occurred_at-ordering. baton-sdk's event-feed contract
  only cares about strict forward progress and resumability; it doesn't
  prescribe a cursor format.
  """

  import Ecto.Query
  alias Symphony.Audit.Event
  alias Symphony.Repo

  @default_limit 50
  @max_limit 250

  @doc """
  Returns `{events, next_cursor, has_more}`. `next_cursor` is `nil` when
  the page is the last one.
  """
  def list_events(opts \\ []) do
    cursor = Keyword.get(opts, :cursor)
    limit = Keyword.get(opts, :limit, @default_limit) |> clamp_limit()
    event_type = Keyword.get(opts, :event_type)

    last_id = decode_cursor(cursor)

    query =
      Event
      |> where([e], e.id > ^last_id)
      |> order_by([e], asc: e.id)
      |> limit(^(limit + 1))

    query = if event_type, do: where(query, [e], e.event_type == ^event_type), else: query

    rows = Repo.all(query)

    {events, has_more} =
      case rows do
        rows when length(rows) > limit ->
          {Enum.take(rows, limit), true}

        rows ->
          {rows, false}
      end

    next_cursor =
      case {has_more, List.last(events)} do
        {true, %Event{id: last}} -> encode_cursor(last)
        _ -> nil
      end

    {events, next_cursor, has_more}
  end

  defp clamp_limit(n) when is_integer(n) and n > 0, do: min(n, @max_limit)
  defp clamp_limit(_), do: @default_limit

  defp decode_cursor(nil), do: 0
  defp decode_cursor(""), do: 0

  defp decode_cursor(cursor) when is_binary(cursor) do
    case Base.url_decode64(cursor, padding: false) do
      {:ok, str} ->
        case Integer.parse(str) do
          {id, ""} -> id
          _ -> 0
        end

      _ ->
        0
    end
  end

  defp encode_cursor(id) do
    Base.url_encode64(Integer.to_string(id), padding: false)
  end
end
