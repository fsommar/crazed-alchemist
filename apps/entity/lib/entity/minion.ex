defmodule Entity.Minion do
  defstruct [entity: %Entity{}, attacker: %Entity.Attacker{}, position: nil]
  
  use Entity
  use Entity.Attacker

end