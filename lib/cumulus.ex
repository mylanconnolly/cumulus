defmodule Cumulus do
  alias Cumulus.Bucket

  @api_host "https://www.googleapis.com"
  @storage_namespace "storage/v1"
  @upload_namespace "upload/storage/v1"
  @auth_scope "https://www.googleapis.com/auth/cloud-platform"

  @doc """
  This is the function responsible for returning the URL of a given bucket /
  object combination.
  """
  def object_url(bucket, object) when is_binary(bucket) and is_binary(object),
    do: "#{bucket_url(bucket)}/#{object_namespace(object)}"

  @doc """
  This is the function responsible for returning the URL of a given bucket.
  """
  def bucket_url(bucket) when is_binary(bucket),
    do: "#{@api_host}/#{@storage_namespace}/#{bucket_namespace(bucket)}"

  @doc """
  This is the function responsible for returning the URL of a given bucket
  for upload purposes. This is separate from `bucket_url/1` because Google
  uses a different endpoint for uploading files.
  """
  def bucket_upload_url(bucket) when is_binary(bucket),
    do: "#{@api_host}/#{@upload_namespace}/#{bucket_namespace(bucket)}/o"

  @doc """
  This is the function responsible for finding a bucket in Google Cloud Storage
  and returning it. Possible return values are:

  - `{:error, :not_found}` is used for buckets that are not found in the system
  - `{:error, :not_authorized}` is used for buckets that you do not have access
    to
  - `{:ok, bucket}` is for successful responses and where we can successfully
    parse the response as a bucket.

  This function will panic in the event that the response could not be
  correctly parsed.
  """
  def get_bucket!(bucket) when is_binary(bucket) do
    case HTTPoison.get(bucket_url(bucket), [auth_header()]) do
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      {:ok, %HTTPoison.Response{status_code: 401}} -> {:error, :not_authorized}
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        bucket =
          body
          |> Poison.decode!()
          |> Bucket.from_json!()
        {:ok, bucket}
      {:error, reason} -> {:error, reason}
    end
  end

  defp auth_header do
    {:ok, %Goth.Token{token: token, type: type}} = Goth.Token.for_scope(@auth_scope)
    {:"Authorization", "#{type} #{token}"}
  end

  defp bucket_namespace(bucket) when is_binary(bucket), do: "b/#{bucket}"

  defp object_namespace(object) when is_binary(object),
    do: "o/#{encode_path_component(object)}"

  defp encode_path_component(component), do: URI.encode_www_form(component)
end
