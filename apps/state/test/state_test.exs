defmodule StateTest do
  use ExUnit.Case

  alias Entity.{Minion, Card, Hero}
  alias State.Player

  doctest State
  doctest State.Player
end
