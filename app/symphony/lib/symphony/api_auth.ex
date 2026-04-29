defmodule Symphony.ApiAuth do
  @moduledoc """
  Bearer-token verification for the Symphony API.

  Tokens are not stored in plaintext. The seeded value is hashed with
  SHA-256 and stored as `sha256:<hex>` in `api_keys.hashed_secret`.
  Verifying a request hashes the bearer the same way and looks up the
  row, then loads the linked Musician (the actor) for downstream authz.
  """

  import Ecto.Query

  alias Symphony.Identity.Musician
  alias Symphony.Repo
  alias Symphony.Secrets.ApiKey

  @doc "Hash a plaintext bearer token in the same shape as `api_keys.hashed_secret`."
  def hash_token(token) when is_binary(token) do
    "sha256:" <> Base.encode16(:crypto.hash(:sha256, token), case: :lower)
  end

  @doc """
  Verify a bearer token. Returns `{:ok, %Musician{}}` on success or `{:error, reason}`.

  Reasons:
    * `:unauthorized` — no matching api_key, expired key, or non-enabled identity
  """
  def verify_token(token) when is_binary(token) and byte_size(token) > 0 do
    hashed = hash_token(token)
    now = DateTime.utc_now()

    query =
      from k in ApiKey,
        join: m in Musician,
        on: m.id == k.identity_id,
        where: k.hashed_secret == ^hashed,
        where: is_nil(k.expires_at) or k.expires_at > ^now,
        where: m.status == :enabled,
        select: {k, m}

    case Repo.one(query) do
      nil ->
        {:error, :unauthorized}

      {api_key, musician} ->
        _ = touch_last_used(api_key)
        {:ok, musician}
    end
  end

  def verify_token(_), do: {:error, :unauthorized}

  defp touch_last_used(%ApiKey{} = api_key) do
    api_key
    |> Ecto.Changeset.change(last_used_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update()
  end
end
