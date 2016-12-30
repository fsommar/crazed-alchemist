defmodule Entity.Player do
  use Entity

  alias Entity.Player

  defstruct [:id, :hero, deck: [], hand: []]

  @doc """
  Creates a player entity.

    iex> Player.create("p1")
    %Player{id: "p1"}

    iex> Player.create("p2", hero: %{name: "Jaina Proudmoore"})
    %Player{
      id:   "p2",
      hero: %{name: "Jaina Proudmoore"}
    }
  """
  def create(id, opts \\ []) do
    player = %Player{
      id: id
    }
    Map.from_struct(player)
    |> Map.keys
    |> Enum.filter(&Keyword.has_key?(opts, &1))
    |> Enum.reduce(player, &Map.put(&2, &1, Keyword.get(opts, &1)))
  end
end