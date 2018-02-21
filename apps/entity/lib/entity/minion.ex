defmodule Entity.Minion do
  use Entity
  use Entity.Attacker

  alias Entity.Minion

  defstruct [entity: %Entity{}, attacker: %Entity.Attacker{}, position: nil]

  @doc """
  Creates a minion entity, given a minion definition, with the provided id.
  The definition is required to have a `:name` key.

    iex> Minion.create(%{:name => "Imp"}, id: "imp-1")
    ...> |> Entity.get(:id)
    "imp-1"

  The definition doesn't have to exist, as long as it has a `:name` key.
  It could be useful for e.g. mocking.

    iex> Minion.create(%{:name => "NOEXIST"}, id: "ne-1")
    ...> |> Entity.get(:name)
    "NOEXIST"
  """
  def create(%{name: name} = _minion, opts \\ []) do
    Entity.apply_opts(%Minion{
      entity: %Entity{
        name: name
      }
    }, opts)
  end

end