defmodule Cumulus.Object do
  alias Cumulus.{ACL, CustomerEncryption, Owner}

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
    time_deleted: nil,
    storage_class: nil,
    time_storage_class_updated: nil,
    size: nil,
    md5hash: nil,
    media_link: nil,
    content_encoding: nil,
    content_disposition: nil,
    content_language: nil,
    cache_control: nil,
    metadata: nil,
    acl: nil,
    owner: nil,
    crc32c: nil,
    component_count: nil,
    etag: nil,
    customer_encryption: nil
  ]

  @doc """
  This is the function used to convert a JSON response into a struct. It
  accepts a map (like what would be decoded by `Poison`) and returns the
  parsed version. It must match the expected schema, otherwise a panic occurs.
  """
  def from_json!(%{
    "id" => id,
    "selfLink" => self_link,
    "name" => name,
    "bucket" => bucket,
    "generation" => generation,
    "metageneration" => metageneration,
    "contentType" => content_type,
    "timeCreated" => time_created,
    "updated" => updated,
    "timeDeleted" => time_deleted,
    "storageClass" => storage_class,
    "timeStorageClassUpdated" => time_storage_class_updated,
    "size" => size,
    "md5hash" => md5hash,
    "mediaLink" => media_link,
    "contentEncoding" => content_encoding,
    "contentDisposition" => content_disposition,
    "contentLanguage" => content_language,
    "cacheControl" => cache_control,
    "crc32c" => crc32c,
    "componentCount" => component_count,
    "etag" => etag,
    "customerEncryption" => customer_encryption,
    "owner" => owner,
    "acl" => acl
  }) do
    %__MODULE__{
      id: id,
      self_link: self_link,
      name: name,
      bucket: bucket,
      generation: generation,
      metageneration: metageneration,
      content_type: content_type,
      time_created: time_created,
      updated: updated,
      time_deleted: time_deleted,
      storage_class: storage_class,
      time_storage_class_updated: time_storage_class_updated,
      size: size,
      md5hash: md5hash,
      media_link: media_link,
      content_encoding: content_encoding,
      content_disposition: content_disposition,
      content_language: content_language,
      cache_control: cache_control,
      crc32c: crc32c,
      component_count: component_count,
      etag: etag,
      customer_encryption: CustomerEncryption.from_json!(customer_encryption),
      owner: Owner.from_json!(owner),
      acl: ACL.from_json!(acl)
    }
  end
end
