defmodule Cumulus.Owner do
  defstruct [entity: nil, entity_id: nil]

  @doc """
  This is the function used to convert a JSON response into a struct. It
  accepts a map (like what would be decoded by `Poison`) and returns the
  parsed version. It must match the expected schema, otherwise a panic occurs.
  """
  def from_json!(%{"entity" => entity, "entityId" => id}),
    do: %__MODULE__{entity: entity, entity_id: id}
end
