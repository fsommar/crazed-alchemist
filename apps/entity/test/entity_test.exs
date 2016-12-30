defmodule EntityTest do
  use ExUnit.Case
  alias Entity.{Attacker, Hero, Minion, Player}

  doctest Entity
  doctest Entity.Attacker
  doctest Entity.Hero
  doctest Entity.Hero.HeroPower
  doctest Entity.Minion
  doctest Entity.Player
end
