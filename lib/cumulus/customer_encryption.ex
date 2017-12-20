defmodule Cumulus.CustomerEncryption do
  defstruct [encryption_algorithm: nil, key_sha256: nil]

  @doc """
  This is the function used to convert a JSON response into a struct. It
  accepts a map (like what would be decoded by `Poison`) and returns the
  parsed version. It must match the expected schema, otherwise a panic occurs.
  """
  def from_json!(%{"encryptionAlgorithm" => algorithm, "keySha256" => sha}),
    do: %__MODULE__{encryption_algorithm: algorithm, key_sha256: sha}
end
