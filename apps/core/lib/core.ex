defmodule Core do
  @moduledoc """
  The players are hardcoded with keys `:player1` and `:player2`.

  The default hero for both players is Jaina Proudmoore.
  """

  @doc """
  Creates a game state, optionally providing initial values, via a keyword list, for the two players.

  The valid keys to populate the players with are `:hero`, `:minions`, `:deck`, and `:hand`.

    iex> Core.create_game
    ...> |> State.get_hero(:player1)
    ...> |> Entity.name
    "Jaina Proudmoore"

    iex> Core.create_game([hero: Core.create_hero "Gul'dan"])
    ...> |> State.get_hero(:player1)
    ...> |> Entity.name
    "Gul'dan"

  If there's a need to only populate the second player, the first player can be provided an empty list `[]`.

    iex> Core.create_game([], [minions: [Core.create_minion("Imp"), Core.create_minion("War Golem", id: "wg-1")]])
    ...> |> State.get_minions(:player2)
    ...> |> Enum.count
    2
  """
  def create_game(player1 \\ [], player2 \\ []) do
    # The optionals are passed to player creation, as they can e.g. read and act on the `:hero` key.
    state = State.create_empty Core.create_player(:player1, player1), Core.create_player(:player2, player2)

    # This takes care of adding minions, and cards to a player's deck and hand.
    Enum.reduce([player1: player1, player2: player2], state, fn {player_id, p}, state ->
      [minions: &Core.place_minion/3, hand: &Core.add_to_hand/3, deck: &Core.add_to_deck/3]
      |> Enum.reduce(state, fn {key, f}, state ->
        Enum.reduce(Keyword.get(p, key, []), state, &f.(&2, player_id, &1))
      end)
    end)
  end

  def place_minion(state, player_id, minion, position \\ nil) do
    minion = %{minion | owner: player_id, position: position}
    State.add_minion state, minion
  end

  def add_to_hand(state, player_id, card) do
    state
  end

  def add_to_deck(state, player_id, card) do
    state
  end

  def create_player(player_id, opts \\ []) do
    Entity.Player.create(player_id, [hero: Core.create_hero("Jaina Proudmoore")] ++ opts)
  end

  def create_hero(name, opts \\ []) do
    Entity.Hero.create(Data.Hero.get(name), opts)
  end

  def create_minion(name, opts \\ []) do
    Entity.Minion.create(Data.Minion.get(name), opts)
  end
end
