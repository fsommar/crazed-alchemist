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
    %Player{
      id: id
    }
    |> Entity.apply_opts(opts)
  end
end