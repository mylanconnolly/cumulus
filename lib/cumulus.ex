defmodule Cumulus do
  alias Cumulus.{Bucket, Object}
  alias HTTPoison.Response

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
  This is the function responsible for returning the URL of a given bucket /
  object combination's media (i.e., the file itself, not the metadata about the
  file).
  """
  def object_media_url(bucket, object) when is_binary(bucket) and is_binary(object),
    do: "#{object_url(bucket, object)}?alt=media"

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
  def bucket_upload_url(bucket, object) when is_binary(bucket) and is_binary(object),
    do: "#{@api_host}/#{@upload_namespace}/#{bucket_namespace(bucket)}/o?uploadType=resumable&name=#{object}"

  @doc """
  This is the function responsible for finding a bucket in Google Cloud Storage
  and returning it. Possible return values are:

  - `{:error, :not_found}` is used for buckets that are not found in the system
  - `{:error, :not_authorized}` is used for buckets that you do not have access
    to
  - `{:error, :invalid_format}` is used for responses where we cannot parse the
    response as a bucket
  - `{:error, :invalid_request}` is used for requests where the bucket name is
    invalid
  - `{:ok, bucket}` is for successful responses and where we can successfully
    parse the response as a bucket
  """
  def get_bucket(bucket) when is_binary(bucket) do
    with {:ok, %Response{body: body, status_code: 200}} <- HTTPoison.get(bucket_url(bucket), [auth_header()]),
         {:ok, data} <- Poison.decode(body),
         {:ok, bucket} <- Bucket.from_json(data) do
      {:ok, bucket}
    else
      {:ok, %Response{status_code: 400}} -> {:error, :invalid_request}
      {:ok, %Response{status_code: 401}} -> {:error, :not_authorized}
      {:ok, %Response{status_code: 404}} -> {:error, :not_found}
      {:error, :invalid_format} -> {:error, :invalid_format}
    end
  end

  @doc """
  This is the function responsible for finding an object in Google Cloud Storage
  and returning it. Possible return values are:

  - `{:error, :not_found}` is used for buckets that are not found in the system
  - `{:error, :not_authorized}` is used for buckets that you do not have access
    to
  - `{:error, :invalid_format}` is used for responses where we cannot parse the
    response as an object
  - `{:error, :invalid_request}` is used for requests where the bucket or
    object name is invalid
  - `{:ok, object}` is for successful responses where we can successfully
    parse the response as an object
  """
  def get_object(bucket, object) when is_binary(bucket) and is_binary(object) do
    with {:ok, %Response{body: body, status_code: 200}} <- HTTPoison.get(object_url(bucket, object), [auth_header()]),
         {:ok, data} <- Poison.decode(body),
         {:ok, object} <- Object.from_json(data) do
      {:ok, object}
    else
      {:ok, %Response{status_code: 400}} -> {:error, :invalid_request}
      {:ok, %Response{status_code: 401}} -> {:error, :not_authorized}
      {:ok, %Response{status_code: 404}} -> {:error, :not_found}
      {:error, :invalid_format} -> {:error, :invalid_format}
    end
  end

  @doc """
  This function is used to save a file into a given bucket.

  - `{:error, :not_found}` is used for buckets that are not found in the system
  - `{:error, :not_authorized}` is used for buckets that you do not have access
    to
  - `{:error, :invalid_request}` is used for requests where the bucket or
    object name is invalid
  - `{:ok, object}` means the file was saved successfully
  """
  def save_object(bucket, object, filepath, key \\ nil, hash \\ nil) do
    headers =
      case [key, hash] do
        [k, h] when is_binary(k) and is_binary(h) -> crypt_headers(k, h)
        _ -> [auth_header()]
      end
    headers = [{:"X-Upload-Content-Type", MIME.from_path(filepath)} | headers]
    case HTTPoison.post(bucket_upload_url(bucket, object), "", headers) do
      {:ok, %Response{status_code: 200, headers: headers}} ->
        location = get_location(headers)
        put_file(location, filepath, key, hash)
      {:ok, %Response{status_code: 400}} -> {:error, :invalid_request}
      {:ok, %Response{status_code: 401}} -> {:error, :not_authorized}
      {:ok, %Response{status_code: 404}} -> {:error, :not_found}
    end
  end

  @doc """
  This is the function responsible for finding an object in Google Cloud Storage
  and returning the file itself. Possible return values are:

  - `{:error, :not_found}` is used for buckets that are not found in the system
  - `{:error, :not_authorized}` is used for buckets that you do not have access
    to
  - `{:error, :invalid_request}` is used for requests where the bucket or
    object name is invalid
  - `{:ok, body}` is used to return the object's contents
  """
  def get_object_media(bucket, object, key \\ nil, hash \\ nil) when is_binary(bucket) and is_binary(object) do
    headers =
      case [key, hash] do
        [k, h] when is_binary(k) and is_binary(h) -> crypt_headers(k, h)
        _ -> [auth_header()]
      end
    case HTTPoison.get(object_media_url(bucket, object), headers) do
      {:ok, %Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %Response{status_code: 400}} -> {:error, :invalid_request}
      {:ok, %Response{status_code: 401}} -> {:error, :not_authorized}
      {:ok, %Response{status_code: 404}} -> {:error, :not_found}
    end
  end

  defp get_location(headers) do
    Enum.reduce(headers, nil, &check_location_header/2)
  end

  defp check_location_header({"Location", value}, _), do: value
  defp check_location_header({_, _}, acc), do: acc

  defp auth_header do
    {:ok, %Goth.Token{token: token, type: type}} = Goth.Token.for_scope(@auth_scope)
    {:Authorization, "#{type} #{token}"}
  end

  defp crypt_headers(key, hash) when is_binary(key) and is_binary(hash) do
    [auth_header() | [
      "x-goog-encryption-algorithm": "AES256",
      "x-goog-encryption-key": key,
      "x-goog-encryption-key-sha256": hash
    ]]
  end

  defp bucket_namespace(bucket) when is_binary(bucket), do: "b/#{bucket}"

  defp object_namespace(object) when is_binary(object),
    do: "o/#{encode_path_component(object)}"

  defp encode_path_component(component), do: URI.encode_www_form(component)

  defp put_file(location, filepath, key \\ nil, hash \\ nil) do
    headers =
      case [key, hash] do
        [k, h] when is_binary(k) and is_binary(h) -> crypt_headers(k, h)
        _ -> [auth_header()]
      end
    with {:ok, bytes} <- File.read(filepath),
         {:ok, %Response{status_code: 200, body: body}} <- HTTPoison.put(location, bytes, headers),
         {:ok, data} <- Poison.decode(body),
         {:ok, object} <- Object.from_json(data) do
      {:ok, object}
     else
       {:ok, %Response{status_code: 400}} -> {:error, :invalid_request}
       {:ok, %Response{status_code: 401}} -> {:error, :not_authorized}
       {:ok, %Response{status_code: 404}} -> {:error, :not_found}
       {:error, :invalid_format} -> {:error, :invalid_format}
    end
  end
end
