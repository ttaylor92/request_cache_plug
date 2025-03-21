defmodule RequestCache do
  @moduledoc """
  #{File.read!("./README.md")}
  """

  @type opts :: [
    ttl: pos_integer,
    cache: module,
    cached_errors: :all | list(atom)
  ]

  @spec store(conn :: Plug.Conn.t, opts_or_ttl :: opts | pos_integer) :: Plug.Conn.t
  @spec store(conn :: any, opts_or_ttl :: opts | pos_integer) :: {:ok, any}
  def store(conn, opts_or_ttl \\ [])

  def store(%Plug.Conn{} = conn, opts_or_ttl) do
    if RequestCache.Config.enabled?() do
      RequestCache.Plug.store_request(conn, opts_or_ttl)
    else
      conn
    end
  end

  if RequestCache.Application.dependency_found?(:absinthe) and
     RequestCache.Application.dependency_found?(:absinthe_plug) do
    def store(result, opts_or_ttl) do
      if RequestCache.Config.enabled?() do
        RequestCache.Middleware.store_result(result, opts_or_ttl)
      else
        result
      end
    end

    def connect_absinthe_context_to_conn(conn, %Absinthe.Blueprint{} = blueprint) do
      Absinthe.Plug.put_options(conn, context: blueprint.execution.context)
    end
  end
end
