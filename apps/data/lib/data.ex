defmodule Data do

    def get_definition(name) do
        Data.Hero.get(name) or Data.Minion.get(name)
    end
end
