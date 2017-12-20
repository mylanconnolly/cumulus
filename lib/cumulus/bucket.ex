defmodule Cumulus.Bucket do
  defstruct [
    id: nil,
    self_link: nil,
    name: nil,
    time_created: nil,
    updated: nil,
    metageneration: nil,
    location: nil,
    storage_class: nil,
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
    "timeCreated" => time_created,
    "updated" => updated,
    "metageneration" => metageneration,
    "location" => location,
    "storageClass" => storage_class,
    "etag" => etag
  }) do
    with {:ok, time_created_ts, _} <- DateTime.from_iso8601(time_created),
         {:ok, updated_ts, _} <- DateTime.from_iso8601(updated) do
      {:ok, %__MODULE__{
        id: id,
        self_link: self_link,
        name: name,
        time_created: time_created_ts,
        updated: updated_ts,
        metageneration: metageneration,
        location: location,
        storage_class: storage_class,
        etag: etag
      }}
    else
      _ -> {:error, :invalid_format}
    end
  end
  def from_json(_), do: {:error, :invalid_format}
end
