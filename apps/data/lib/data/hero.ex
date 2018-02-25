defmodule Data.Hero do
  @enforce_keys [:hero_power]
  defstruct [:name, :hero_power, :health, :mana]

  @doc """
  Returns the definition for a Hero by name.

    iex> Data.Hero.get "Jaina Proudmoore"
    %Data.Hero{
      name:       "Jaina Proudmoore",
      hero_power: "Fireblast",
      health:     30,
      mana:       10
    }

    iex> Data.Hero.get "NOEXIST"
    nil
  """
  def get(name) do
    if Data.Hero.exists? name do
      %{definitions()[name] | name: name, health: 30, mana: 10}
    end
  end

  @doc """
  Returns whether a Hero by the provided name exists.
  """
  def exists?(name) do
    Map.has_key? definitions(), name
  end

  defp definitions() do
    %{
      "Jaina Proudmoore" => %Data.Hero{
        hero_power: "Fireblast"
      },

      "Gul'dan" => %Data.Hero{
        hero_power: "Life Tap"
      }
    }
  end
end