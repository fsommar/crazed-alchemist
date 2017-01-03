defmodule Entity.Hero do
  use Entity
  use Entity.Attacker

  defstruct [mana: 1, mana_used: 0,
             hero_power: %Entity.Hero.HeroPower{},
             entity: %Entity{}, attacker: %Entity.Attacker{}]

  @doc """
  Creates a hero entity, optionally populating the fields with a keyword list.

    iex> Entity.Hero.create %{name: "Jaina Proudmoore"}, mana: 10, mana_used: 5
    %Entity.Hero{mana: 10, mana_used: 5, entity: %Entity{name: "Jaina Proudmoore"}}
  """
  def create(%{name: name} = _hero, opts \\ []) do
    Entity.apply_opts %Entity.Hero{}, opts ++ [name: name]
  end

end