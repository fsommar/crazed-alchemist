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
end