defmodule Entity.Minion do
  use Entity
  use Entity.Attacker

  defstruct [entity: %Entity{}, attacker: %Entity.Attacker{}]

  @doc """
  Creates a minion entity, given a minion definition, with the provided id.
  The definition is required to have a `:name` key.

    iex> Entity.Minion.create(%{:name => "Imp"}, id: "imp-1")
    ...> |> Entity.id
    "imp-1"

  The definition doesn't have to exist, as long as it has a `:name` key.
  It could be useful for e.g. mocking.

    iex> Entity.Minion.create(%{:name => "NOEXIST"}, id: "ne-1")
    ...> |> Entity.name
    "NOEXIST"
  """
  def create(%{name: name} = _minion, opts \\ []) do
    Entity.apply_opts(%Entity.Minion{
      entity: %Entity{
        name: name
      }
    }, opts)
  end
end