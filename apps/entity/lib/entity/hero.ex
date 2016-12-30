defmodule Entity.Hero do
  use Entity
  use Entity.Attacker

  defstruct [mana: 1, mana_used: 0,
             hero_power: %Entity.Hero.HeroPower{},
             entity: %Entity{}, attacker: %Entity.Attacker{}]

end