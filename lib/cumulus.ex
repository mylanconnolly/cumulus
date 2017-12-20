defmodule Cumulus do
  @api_host "https://www.googleapis.com"
  @storage_namespace "storage/v1"
  @upload_namespace "upload/storage/v1"

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

  defp bucket_namespace(bucket) when is_binary(bucket), do: "b/#{bucket}"

  defp object_namespace(object) when is_binary(object),
    do: "o/#{encode_path_component(object)}"

  defp encode_path_component(component), do: URI.encode_www_form(component)
end
