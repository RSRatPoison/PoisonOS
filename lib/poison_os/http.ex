defmodule PoisonOS.HTTP do
  @moduledoc """
  A minimal HTTP client built on top of Erlang's `:httpc`.

  The client offers two convenience functions – `get/1` and `post/3` – that
  wrap the low‑level `:httpc` API.  Responses are returned as a tuple containing
  the HTTP status code, a list of header tuples and the response body.

  ## Public API

    * `get/1` – performs an HTTP GET request. Returns
      `{:ok, status_code, headers, body}` on success, or `{:error, reason}` on
      failure.

    * `post/3` – performs an HTTP POST request. Returns
      `{:ok, status_code, headers, body}` on success, or `{:error, reason}` on
      failure.

  The functions never raise; all errors are wrapped in `{:error, reason}`.
  """

  @doc """
  Performs an HTTP GET request to the given URL.

  Returns `{:ok, status_code, headers, body}` where:

    * `status_code` – the numeric HTTP status code,
    * `headers` – a list of `{name, value}` tuples with header names and values as
      strings,
    * `body` – the raw response body as a binary.

  Returns `{:error, reason}` if the request cannot be completed.
  """
  @spec get(String.t()) ::
          {:ok, non_neg_integer(), [{String.t(), String.t()}], binary()}
          | {:error, term()}
  def get(url) do
    do_request(:get, url, "", [])
  end

  @doc """
  Performs an HTTP POST request to the given URL with the provided body and
  optional headers.

  Returns `{:ok, status_code, headers, body}` on success, mirroring the format
  of `get/1`. Returns `{:error, reason}` on failure.
  """
  @spec post(String.t(), binary(), [{String.t(), String.t()}]) ::
          {:ok, non_neg_integer(), [{String.t(), String.t()}], binary()}
          | {:error, term()}
  def post(url, body, headers \\ []) do
    do_request(:post, url, body, headers)
  end

  # Internal helpers ---------------------------------------------------------

  @doc false
  @spec do_request(:get | :post, String.t(), binary(), [{String.t(), String.t()}]) ::
          {:ok, non_neg_integer(), [{String.t(), String.t()}], binary()}
          | {:error, term()}
  defp do_request(method, url, body, headers) do
    with :ok <- ensure_httpc_started(),
         {:ok, {{_, status, _}, resp_headers, resp_body}} <-
           :httpc.request(
             method,
             to_request_url(url),
             to_request_headers(headers),
             to_request_body(body)
           ) do
      {:ok, status, normalize_headers(resp_headers), resp_body}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  @spec ensure_httpc_started() :: :ok | {:error, term()}
  defp ensure_httpc_started do
    case :inets.start() do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  @spec to_request_url(String.t()) :: :uri_string.uri()
  defp to_request_url(url) do
    case URI.parse(url) do
      %URI{scheme: nil} -> URI.parse("http://" <> url)
      parsed -> parsed
    end
  end

  @doc false
  @spec to_request_headers([{String.t(), String.t()}]) :: [{charlist(), charlist()}]
  defp to_request_headers(headers) do
    Enum.map(headers, fn {name, value} -> {to_charlist(name), to_charlist(value)} end)
  end

  @doc false
  @spec to_request_body(binary()) :: binary()
  defp to_request_body(body), do: body

  @doc false
  @spec normalize_headers([{charlist(), charlist()}]) :: [{String.t(), String.t()}]
  defp normalize_headers(headers) do
    Enum.map(headers, fn {name, value} -> {to_string(name), to_string(value)} end)
  end
end
