defmodule Entity.Hero do
  defstruct mana: 1,
            mana_used: 0,
            fatigue: 0,
            hero_power: %Entity.Hero.HeroPower{},
            entity: %Entity{},
            attacker: %Entity.Attacker{}

  use Entity
  use Entity.Attacker

end