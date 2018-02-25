defmodule Data.Minion do

  @enforce_keys [:attack, :health, :mana_cost]
  defstruct [:name, :attack, :health, :mana_cost, :race, :rarity,
             :battlecry, :combo, :target, :condition, :trigger,
             :description, :type]

  @doc """
  Returns the definition for a minion by name.

    iex> Data.Minion.get "Imp"
    %Data.Minion{
      name:      "Imp",
      attack:    1,
      health:    1,
      mana_cost: 1,
      race:      :demon,
      type:      :minion
    }

    iex> Data.Minion.get "NOEXIST"
    nil
  """
  def get(name) do
    if Data.Minion.exists? name do
      %{definitions()[name] | name: name, type: :minion}
    end
  end

  @doc """
  Returns whether a minion by the provided name exists.

    iex> Data.Minion.exists? "Imp"
    true

    iex> Data.Minion.exists? "NOEXIST"
    false
  """
  def exists?(name) do
    Map.has_key? definitions(), name
  end

  defp definitions() do
    %{
      "Imp" => %Data.Minion{
        attack:    1,
        health:    1,
        mana_cost: 1,
        race:      :demon
      },

      "War Golem" => %Data.Minion{
        attack:    6,
        health:    7,
        mana_cost: 6
      }
    }
  end
end