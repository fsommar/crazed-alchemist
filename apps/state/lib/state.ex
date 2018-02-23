defmodule State do
  alias Entity.Player
  alias Entity.Minion

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
    |> Enum.filter(&(Entity.get(&1, :owner) == player_id))
  end

  @doc """
  Returns the hand for a player.

    iex> State.get_hand State.create_empty, "p1"
    MapSet.new()

    iex> State.create_empty
    ...> |> State.add_to_hand("p1", "x")
    ...> |> State.get_hand("p1")
    MapSet.new(["x"])
  """
  def get_hand(state, player_id) do
    state
    |> State.get_player(player_id)
    |> Map.get(:hand)
    |> MapSet.new()
  end

  @doc """
  Returns the deck for a player in an ordered list.

    iex> State.get_deck State.create_empty, "p1"
    []

    iex> State.create_empty
    ...> |> State.add_to_deck("p1", "x")
    ...> |> State.add_to_deck("p1", "y")
    ...> |> State.get_deck("p1")
    ["x", "y"]
  """
  def get_deck(state, player_id) do
    state
    |> State.get_player(player_id)
    |> Map.get(:deck)
  end

  @doc """
  Adds a player's minion to the board.

    iex> State.place_minion State.create_empty, "p1", Minion.create(%{name: "Imp"})
    %{State.create_empty | board: [Minion.create(%{name: "Imp"}, owner: "p1")]}
  """
  def place_minion(state, player_id, %Minion{} = minion, position \\ nil) do
    board_minion = Entity.apply_opts(minion, position: position, owner: player_id)
    state
    |> Map.update(:board, [], fn(board) -> [board_minion | board] end)
  end

  @doc """
  Adds a card to a player's hand.

    iex> State.create_empty
    ...> |> State.add_to_hand("p1", "Card1")
    ...> |> State.add_to_hand("p1", "Card2")
    ...> |> State.get_hand("p1")
    MapSet.new(["Card2", "Card1"])
  """
  def add_to_hand(state, player_id, card) do
    state
    |> State.update_player(player_id, fn(m) ->
      Map.update!(m, :hand, &(List.insert_at(&1, -1, card)))
    end)
  end

  @doc """
  Adds a card to the bottom of a player's deck.

    iex> State.create_empty
    ...> |> State.add_to_deck("p1", "Card1")
    ...> |> State.add_to_deck("p1", "Card2")
    ...> |> State.get_deck("p1")
    ["Card1", "Card2"]
  """
  def add_to_deck(state, player_id, card) do
    state
    |> State.update_player(player_id, fn(m) ->
      Map.update!(m, :deck, &(List.insert_at(&1, -1, card)))
    end)
  end

  @doc """
  Updates the player with the given id.

    iex> State.create_empty
    ...> |> State.update_player("p1", fn(p) -> %{p | deck: ["x"]} end)
    ...> |> State.get_player("p1")
    %{Player.create("p1") | deck: ["x"]}
  """
  def update_player(%State{} = state, player_id, func) do
    player_with_id = fn(id) ->
      fn :get_and_update, list, next_op ->
        index = Enum.find_index(list, fn(x) -> Map.get(x, :id) == id end)
        item = Enum.at(list, index)

        {_, updated_item} = next_op.(item)
        {item, List.replace_at(list, index, updated_item)}
      end
    end

    state
    |> update_in([Access.key(:players), player_with_id.(player_id)], func)
  end

end