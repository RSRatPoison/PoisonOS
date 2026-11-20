defmodule PoisonOS.HTTP do
  @moduledoc """
  A minimal HTTP client built on top of `:httpc`.

  ## Public API

  * `get/1` – performs an HTTP GET request. Returns `{:ok, status_code, headers, body}`
    on success, or `{:error, reason}` on failure.
  * `post/3` – performs an HTTP POST request. Returns `{:ok, status_code, headers, body}`
    on success, or `{:error, reason}` on failure.
  """

  @doc """
  Performs an HTTP GET request to the given URL.

  Returns `{:ok, status_code, headers, body}` where `status_code` is an integer,
  `headers` is a list of `{name, value}` tuples, and `body` is a binary.
  Returns `{:error, reason}` if the request fails.
  """
  @spec get(String.t()) ::
          {:ok, non_neg_integer(), [{String.t(), String.t()}], binary()}
          | {:error, term()}
  def get(url) do
    do_request(:get, url, "", [])
  end

  @doc """
  Performs an HTTP POST request to the given URL with the provided body and headers.

  Returns `{:ok, status_code, headers, body}` where `status_code` is an integer,
  `headers` is a list of `{name, value}` tuples, and `body` is a binary.
  Returns `{:error, reason}` if the request fails.
  """
  @spec post(String.t(), binary(), [{String.t(), String.t()}]) ::
          {:ok, non_neg_integer(), [{String.t(), String.t()}], binary()}
          | {:error, term()}
  def post(url, body, headers \\ []) do
    do_request(:post, url, body, headers)
  end

  defp do_request(method, url, body, headers) do
    with :ok <- ensure_httpc_started(),
         {:ok, {_, status, resp_headers}} <-
           :httpc.request(
             method,
             to_request_url(url),
             to_request_headers(headers),
             to_request_body(body)
           ),
         {:ok, resp_body} <- :httpc.response_body(resp_headers, status) do
      {:ok, status, normalize_headers(resp_headers), resp_body}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp ensure_httpc_started do
    case :inets.start() do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp to_request_url(url) do
    case URI.parse(url) do
      %URI{scheme: nil} -> URI.parse("http://" <> url)
      parsed -> parsed
    end
  end

  defp to_request_headers(headers) do
    Enum.map(headers, fn {name, value} -> {to_charlist(name), to_charlist(value)} end)
  end

  defp to_request_body(body) do
    body
  end

  defp normalize_headers(headers) do
    Enum.map(headers, fn {name, value} -> {to_string(name), to_string(value)} end)
  end
end
