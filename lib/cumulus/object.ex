defmodule Cumulus.Object do
  defstruct [
    id: nil,
    self_link: nil,
    name: nil,
    bucket: nil,
    generation: nil,
    metageneration: nil,
    content_type: nil,
    time_created: nil,
    updated: nil,
    storage_class: nil,
    time_storage_class_updated: nil,
    size: nil,
    md5_hash: nil,
    media_link: nil,
    crc32c: nil,
    etag: nil
  ]

  @doc """
  This is the function used to convert a JSON response into a struct. It
  accepts a map (like what would be decoded by `Poison`) and returns the
  parsed version.
  """
  def from_json(%{
    "id" => id,
    "selfLink" => self_link,
    "name" => name,
    "bucket" => bucket,
    "generation" => generation,
    "metageneration" => metageneration,
    "contentType" => content_type,
    "timeCreated" => time_created,
    "updated" => updated,
    "storageClass" => storage_class,
    "timeStorageClassUpdated" => time_storage_class_updated,
    "size" => size,
    "md5Hash" => md5_hash,
    "mediaLink" => media_link,
    "crc32c" => crc32c,
    "etag" => etag
  }) do
    with {:ok, time_created_ts, _} <- DateTime.from_iso8601(time_created),
         {:ok, updated_ts, _} <- DateTime.from_iso8601(updated),
         {:ok, time_storage_class_updated_ts, _} <- DateTime.from_iso8601(time_storage_class_updated) do
      {:ok, %__MODULE__{
        id: id,
        self_link: self_link,
        name: name,
        bucket: bucket,
        generation: generation,
        metageneration: metageneration,
        content_type: content_type,
        time_created: time_created_ts,
        updated: updated_ts,
        storage_class: storage_class,
        time_storage_class_updated: time_storage_class_updated_ts,
        size: size,
        md5_hash: md5_hash,
        media_link: media_link,
        crc32c: crc32c,
        etag: etag
      }}
    else
      _ -> {:error, :invalid_format}
    end
  end
  def from_json(body) do
    IO.inspect body
    {:error, :invalid_format}
  end
end
