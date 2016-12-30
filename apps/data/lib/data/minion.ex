defmodule Data.Minion do

  @enforce_keys [:attack, :health, :mana_cost]
  defstruct [:attack, :health, :mana_cost, :race, :rarity,
             :battlecry, :combo, :target, :condition, :trigger,
             :description, type: :minion]

  @doc """
  Returns the definition for a minion by name.

    iex> Data.Minion.get "Imp"
    %Data.Minion{
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
    definitions[name]
  end

  defp definitions do
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