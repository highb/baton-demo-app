defmodule SymphonyWeb.Api.EventController do
  @moduledoc """
  GET /api/v1/events — cursor-paginated event feed.

  Query params:
    * `cursor` — Base64url-encoded last-seen id; omit for first page.
    * `limit` — max events per page (default 50, max 250).
    * `event_type` — optional filter: `usage` / `resource_change` /
      `create_grant` / `create_revoke`.

  Response shape: `{events, cursor, has_more}` matching baton-sdk's
  `ListEventsResponse`.
  """

  use SymphonyWeb, :controller

  alias Symphony.Audit.Event
  alias Symphony.EventFeed

  def index(conn, params) do
    opts =
      []
      |> maybe_put(:cursor, Map.get(params, "cursor"))
      |> maybe_put(:limit, parse_int(Map.get(params, "limit")))
      |> maybe_put(:event_type, Map.get(params, "event_type"))

    {events, next_cursor, has_more} = EventFeed.list_events(opts)

    json(conn, %{
      events: Enum.map(events, &serialize/1),
      cursor: next_cursor,
      has_more: has_more
    })
  end

  defp serialize(%Event{} = e) do
    %{
      id: e.id,
      occurred_at: e.occurred_at,
      event_type: to_string(e.event_type),
      actor: actor_or_target(e.actor_resource_kind, e.actor_resource_id),
      target: actor_or_target(e.target_resource_kind, e.target_resource_id),
      entitlement_slug: e.entitlement_slug,
      payload: e.payload
    }
  end

  defp actor_or_target(nil, _), do: nil
  defp actor_or_target(_, nil), do: nil
  defp actor_or_target(kind, id), do: %{resource_type: kind, id: id}

  defp maybe_put(opts, _, nil), do: opts
  defp maybe_put(opts, _, ""), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)

  defp parse_int(nil), do: nil
  defp parse_int(""), do: nil

  defp parse_int(s) when is_binary(s) do
    case Integer.parse(s) do
      {n, ""} -> n
      _ -> nil
    end
  end
end
