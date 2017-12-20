defmodule Cumulus.ProjectTeam do
  defstruct [project_id: nil, team: nil]

  @doc """
  This is the function used to convert a JSON response into a struct. It
  accepts a map (like what would be decoded by `Poison`) and returns the
  parsed version. It must match the expected schema, otherwise a panic occurs.
  """
  def from_json!(%{"projectId" => id, "team" => team}),
    do: %__MODULE__{project_id: id, team: team}
end
