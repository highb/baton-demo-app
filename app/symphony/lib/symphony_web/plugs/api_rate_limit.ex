defmodule SymphonyWeb.Plugs.ApiRateLimit do
  @moduledoc """
  Per-API-key rate limiting. Reads `:current_actor` (set by `ApiAuth`)
  and consults `Symphony.RateLimit` for the appropriate bucket
  (`:read` for GET/HEAD, `:write` otherwise).

  On allow: sets `X-RateLimit-Limit` and `X-RateLimit-Remaining`
  response headers.

  On deny: 429 with `Retry-After` header (seconds, rounded up) and a
  JSON body that includes a `rate_limit` annotation matching baton-sdk's
  `c1.connector.v2.RateLimitDescription` shape so the connector's
  `pkg/ratelimit` exercises end-to-end.
  """

  import Plug.Conn

  alias Symphony.RateLimit

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_actor] do
      nil ->
        # ApiAuth should have halted before us; if it didn't, let the
        # request through unmodified and let downstream gates handle it.
        conn

      actor ->
        bucket = bucket_for(conn.method)
        do_check(conn, actor.id, bucket)
    end
  end

  defp do_check(conn, actor_id, bucket) do
    case RateLimit.check(actor_id, bucket) do
      {:allow, count, limit} ->
        conn
        |> put_resp_header("x-ratelimit-limit", Integer.to_string(limit))
        |> put_resp_header("x-ratelimit-remaining", Integer.to_string(max(limit - count, 0)))

      {:deny, retry_after_ms, limit} ->
        retry_after_s = max(div(retry_after_ms + 999, 1000), 1)
        reset_at = DateTime.utc_now() |> DateTime.add(retry_after_ms, :millisecond)

        body = %{
          error: "rate_limited",
          retry_after_ms: retry_after_ms,
          rate_limit: %{
            status: "overlimit",
            limit: limit,
            remaining: 0,
            reset_at: DateTime.to_iso8601(reset_at)
          }
        }

        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("retry-after", Integer.to_string(retry_after_s))
        |> put_resp_header("x-ratelimit-limit", Integer.to_string(limit))
        |> put_resp_header("x-ratelimit-remaining", "0")
        |> send_resp(429, Jason.encode!(body))
        |> halt()
    end
  end

  defp bucket_for("GET"), do: :read
  defp bucket_for("HEAD"), do: :read
  defp bucket_for(_), do: :write
end
