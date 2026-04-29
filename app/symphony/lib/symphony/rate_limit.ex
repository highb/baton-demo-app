defmodule Symphony.RateLimit do
  @moduledoc """
  ETS-backed token-bucket rate limit for the Symphony API.

  Two buckets, keyed per `(api_key_id, bucket)`:

    * `:read`  — 6000/min (~100/sec). Generous default for connector
      sync; deliberately roomy so the demo doesn't trip casually.
    * `:write` — 600/min (~10/sec). Tighter, matches typical upstream
      grant/revoke ergonomics.

  Returns `{:allow, count}` or `{:deny, retry_after_ms}`.
  """

  use Hammer, backend: :ets

  @read_limit 6000
  @write_limit 600
  @scale_ms 60_000

  @doc """
  Check the bucket for the given actor + bucket-kind. Returns
  `{:allow, count}` on success or `{:deny, retry_after_ms, limit}` when
  over.
  """
  def check(actor_id, :read), do: do_check("read:#{actor_id}", @read_limit)
  def check(actor_id, :write), do: do_check("write:#{actor_id}", @write_limit)

  def limit_for(:read), do: @read_limit
  def limit_for(:write), do: @write_limit
  def scale_ms, do: @scale_ms

  defp do_check(key, limit) do
    case hit(key, @scale_ms, limit) do
      {:allow, count} -> {:allow, count, limit}
      {:deny, retry_after_ms} -> {:deny, retry_after_ms, limit}
    end
  end
end
