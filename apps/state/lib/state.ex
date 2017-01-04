defmodule State do
  alias Entity.Player

  defstruct id:             "game1",
            player_in_turn: "p1",
            board:          [],
            players:        []

  @doc """
  Creates an empty game state, with heroes if provided.

    iex> State.create_empty
    %State{
      :id             => "game1",
      :player_in_turn => "p1",
      :board          => [],
      :players        => [
        %Player{
          id:   "p1",
          deck: [],
          hand: [],
          hero: nil
        },
        %Player{
          id:   "p2",
          deck: [],
          hand: [],
          hero: nil
        }
      ]
    }
  """
  def create_empty(p1 \\ nil, p2 \\ nil) do
    %State{
      players: [
        p1 || Player.create("p1"),
        p2 || Player.create("p2")
      ]
    }
  end

  @doc """
  Returns the players in the given state.

    iex> State.get_players State.create_empty
    [Player.create("p1"), Player.create("p2")]
  """
  def get_players(%State{players: players}) do
    players
  end

  @doc """
  Returns the player with the given id.

    iex> State.get_player State.create_empty, "p1"
    Player.create "p1"

    iex> State.get_player State.create_empty, "not-here"
    nil
  """
  def get_player(%State{} = state, id) do
    State.get_players(state)
    |> Enum.filter(fn(x) -> x.id == id end)
    |> List.first
  end

  @doc """
  Returns the hero for the player with the given id.

    iex> State.get_hero State.create_empty, "p1"
    Map.get(Player.create("p1"), :hero)
  """
  def get_hero(state, player_id) do
    State.get_player(state, player_id)
    |> Map.get(:hero)
  end

  @doc """
  Returns the minions for a player.

    iex> State.get_minions State.create_empty, "p1"
    []

    iex> %{State.create_empty | board: [Minion.create(%{name: "Imp"}, owner: "p1"), Minion.create(%{name: "War Golem"}, owner: "p2")]}
    ...> |> State.get_minions("p1")
    [Minion.create(%{name: "Imp"}, owner: "p1")]
  """
  def get_minions(state, player_id) do
    state
    |> Map.get(:board)
    |> Enum.filter(&(Entity.owner(&1) == player_id))
  end
end