defmodule State.Player do

  defstruct [:id, :hero, deck: [], hand: []]

  @doc """
  Creates a player map.

      iex> Player.create("p1")
      %Player{id: "p1"}

      iex> Player.create(:p2, hero: %{name: "Jaina Proudmoore"})
      %Player{
        id:   :p2,
        hero: %{name: "Jaina Proudmoore"}
      }
  """
  def create(id, opts \\ []) do
    %__MODULE__{
      id: id
    }
    |> Entity.apply_opts(opts)
  end

  def update_hero(%__MODULE__{} = player, func) do
    Map.update!(player, :hero, func)
  end
end