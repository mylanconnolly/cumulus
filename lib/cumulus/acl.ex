defmodule Cumulus.ACL do
  alias Cumulus.ProjectTeam

  defstruct [
    id: nil,
    self_link: nil,
    bucket: nil,
    object: nil,
    generation: nil,
    entity: nil,
    role: nil,
    email: nil,
    entity_id: nil,
    domain: nil,
    project_team: nil,
    etag: nil
  ]

  @doc """
  This is the function used to convert a JSON response into a struct. It
  accepts a map (like what would be decoded by `Poison`) and returns the
  parsed version. It must match the expected schema, otherwise a panic occurs.

  If a list is passed in, it converts it into a list of structs.
  """
  def from_json!(acl) when is_list(acl), do: Enum.map(acl, &from_json!/1)
  def from_json!(%{
    "id" => id,
    "selfLink" => self_link,
    "bucket" => bucket,
    "object" => object,
    "generation" => generation,
    "entity" => entity,
    "role" => role,
    "email" => email,
    "entityId" => entity_id,
    "domain" => domain,
    "projectTeam" => project_team,
    "etag" => etag
  }) do
    %__MODULE__{
      id: id,
      self_link: self_link,
      bucket: bucket,
      object: object,
      generation: generation,
      entity: entity,
      role: role,
      email: email,
      entity_id: entity_id,
      domain: domain,
      project_team: ProjectTeam.from_json!(project_team),
      etag: etag
    }
  end
end
