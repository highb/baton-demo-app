defmodule SymphonyWeb.Plugs.ApiAuth do
  @moduledoc """
  Reads `Authorization: Bearer <token>` and assigns the resolved Musician
  as `:current_actor`. Halts with a 401 JSON body otherwise.
  """

  import Plug.Conn
  alias Symphony.ApiAuth

  def init(opts), do: opts

  def call(conn, _opts) do
    with [bearer] <- get_req_header(conn, "authorization"),
         "Bearer " <> token <- bearer,
         {:ok, actor} <- ApiAuth.verify_token(String.trim(token)) do
      assign(conn, :current_actor, actor)
    else
      _ -> deny(conn)
    end
  end

  defp deny(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, ~s({"error":"unauthorized"}))
    |> halt()
  end
end
