defmodule State do
  alias State.Player
  alias Entity.{Minion, Card, Hero}

  defstruct id:             :game1,
            player_in_turn: nil,
            board:          [],
            players:        []

  @doc """
  Creates an empty game state, with heroes if provided.

      iex> State.create
      %State{
        :id             => :game1,
        :player_in_turn => :player1,
        :board          => [],
        :players        => [
          %Player{
            id:   :player1,
            deck: [],
            hand: [],
            hero: nil
          },
          %Player{
            id:   :player2,
            deck: [],
            hand: [],
            hero: nil
          }
        ]
      }
  """
  def create(%Player{} = p1 \\ Player.create(:player1),
             %Player{} = p2 \\ Player.create(:player2)) do
    %__MODULE__{
      players: [p1, p2],
      player_in_turn: p1.id
    }
  end

  @doc """
  Returns the players in the given state.

      iex> State.get_players State.create
      [Player.create(:player1), Player.create(:player2)]
  """
  def get_players(%__MODULE__{players: players}) do
    players
  end

  @doc """
  Returns the player with the given id.

      iex> State.get_player State.create, :player1
      Player.create :player1

      iex> State.get_player State.create, "not-here"
      nil
  """
  def get_player(%__MODULE__{} = state, id) do
    get_players(state)
    |> Enum.filter(fn(x) -> x.id == id end)
    |> List.first()
  end

  @doc """
  Returns the hero for the player with the given id.

      iex> State.get_hero State.create, :player1
      Map.get(Player.create(:player1), :hero)
  """
  def get_hero(%__MODULE__{} = state, player_id) do
    get_player(state, player_id)
    |> Map.get(:hero)
  end

  @doc """
  Returns the minions for a player.

      iex> State.get_minions State.create, :player1
      []

      iex> %{State.create | board: [Minion.create(%{name: "Imp"}, owner: :player1),
      ...>                          Minion.create(%{name: "War Golem"}, owner: :player2)]}
      ...> |> State.get_minions(:player1)
      [Minion.create(%{name: "Imp"}, owner: :player1)]
  """
  def get_minions(%__MODULE__{} = state, player_id) do
    state
    |> Map.get(:board)
    |> Enum.filter(&(Entity.get(&1, :owner) == player_id))
  end

  @doc """
  Returns the hand for a player.

      iex> State.get_hand State.create, :player1
      MapSet.new()

      iex> State.create
      ...> |> State.add_to_hand(:player1, "x")
      ...> |> State.get_hand(:player1)
      MapSet.new(["x"])
  """
  def get_hand(%__MODULE__{} = state, player_id) do
    state
    |> get_player(player_id)
    |> Map.get(:hand)
    |> MapSet.new()
  end

  @doc """
  Returns the deck for a player in an ordered list.

      iex> State.get_deck State.create, :player1
      []

      iex> State.create
      ...> |> State.add_to_deck(:player1, "x")
      ...> |> State.add_to_deck(:player1, "y")
      ...> |> State.get_deck(:player1)
      ["x", "y"]
  """
  def get_deck(%__MODULE__{} = state, player_id) do
    state
    |> get_player(player_id)
    |> Map.get(:deck)
  end

  @doc """
  Returns the player's entity that first matches the provided id,
  in order hero, board, hand, deck.

      iex> state = State.add_to_deck(State.create, :player1, Minion.create(%{name: "Deck"}, id: :x))
      iex> State.get_entity(state, :player1, :x)
      ...> |> Entity.get(:name)
      "Deck"
      iex> state = State.add_to_hand(state, :player1, Minion.create(%{name: "Hand"}, id: :x))
      iex> State.get_entity(state, :player1, :x)
      ...> |> Entity.get(:name)
      "Hand"
      iex> state = State.place_minion(state, :player1, Minion.create(%{name: "Board"}, id: :x))
      iex> State.get_entity(state, :player1, :x)
      ...> |> Entity.get(:name)
      "Board"
      iex> state = State.replace_hero(state, :player1, Hero.create(%{name: "Hero"}, id: :x))
      iex> State.get_entity(state, :player1, :x)
      ...> |> Entity.get(:name)
      "Hero"
  """
  def get_entity(%__MODULE__{} = state, player_id, entity_id) do
    [&[get_hero(&1, &2)], &get_minions/2, &get_hand/2, &get_deck/2]
    |> Stream.flat_map(& &1.(state, player_id))
    |> Stream.reject(&is_nil/1)
    |> Enum.find(&(Entity.get(&1, :id) == entity_id))
  end

  @doc """
  Replaces a player's hero.

  The current hero's id will be used in case the new hero doesn't have one.

      iex> State.create(Player.create(:player1, hero: Hero.create(%{name: "Gul'dan"}, id: :h1)))
      ...> |> State.replace_hero(:player1, Hero.create(%{name: "Thrall"}))
      ...> |> State.get_hero(:player1)
      Hero.create(%{name: "Thrall"}, id: :h1)

      iex> State.create(Player.create(:player1, hero: Hero.create(%{name: "Gul'dan"}, id: :h1)))
      ...> |> State.replace_hero(:player1, Hero.create(%{name: "Thrall"}, id: :thrall))
      ...> |> State.get_hero(:player1)
      Hero.create(%{name: "Thrall"}, id: :thrall)
  """
  def replace_hero(%__MODULE__{} = state, player_id, %Hero{} = hero) do
    hero_id = case Entity.get(hero, :id) do
      nil -> get_hero(state, player_id) |> Entity.get(:id)
      id  -> id
    end
    update_player(state, player_id, fn player ->
      Map.put(player, :hero, Entity.apply_opts(hero, id: hero_id))
    end)
  end

  @doc """
  Adds a player's minion to the board.

      iex> State.place_minion State.create, :player1, Minion.create(%{name: "Imp"})
      %{State.create | board: [Minion.create(%{name: "Imp"}, owner: :player1)]}
  """
  def place_minion(%__MODULE__{} = state, player_id, %Minion{} = minion, position \\ nil) do
    board_minion = Entity.apply_opts(minion, position: position, owner: player_id)
    Map.update(state, :board, [], fn board -> [board_minion | board] end)
  end

  @doc """
  Adds a card to a player's hand.

      iex> State.create
      ...> |> State.add_to_hand(:player1, "Card1")
      ...> |> State.add_to_hand(:player1, "Card2")
      ...> |> State.get_hand(:player1)
      MapSet.new(["Card2", "Card1"])
  """
  def add_to_hand(%__MODULE__{} = state, player_id, card) do
    update_player(state, player_id, fn m ->
      Map.update!(m, :hand, &List.insert_at(&1, -1, card))
    end)
  end

  @doc """
  Adds a card to the bottom of a player's deck.

      iex> State.create
      ...> |> State.add_to_deck(:player1, "Card1")
      ...> |> State.add_to_deck(:player1, "Card2")
      ...> |> State.get_deck(:player1)
      ["Card1", "Card2"]
  """
  def add_to_deck(%__MODULE__{} = state, player_id, card) do
    update_player(state, player_id, fn m ->
      Map.update!(m, :deck, &List.insert_at(&1, -1, card))
    end)
  end

  @doc """
  Shows the first card in a player's deck.

      iex> State.create
      ...> |> State.add_to_deck(:player1, :card1)
      ...> |> State.add_to_deck(:player1, :card2)
      ...> |> State.peek_deck(:player1)
      :card1
  """
  def peek_deck(%__MODULE__{} = state, player_id) do
    state
    |> get_deck(player_id)
    |> List.first()
  end

  @doc """
  Removes the first card in a player's deck and returns it in a pair
  together with the updated state.

      iex> State.create
      ...> |> State.add_to_deck(:player1, :card1)
      ...> |> State.add_to_deck(:player1, :card2)
      ...> |> State.pop_deck(:player1)
      {:card1, State.add_to_deck(State.create, :player1, :card2)}
  """
  def pop_deck(%__MODULE__{} = state, player_id) do
    top_card = peek_deck(state, player_id)
    new_state = update_player(state, player_id, fn m ->
      Map.update!(m, :deck, &List.delete_at(&1, 0))
    end)

    {top_card, new_state}
  end

  @doc """
  Removes a card from a player's hand.

      iex> State.create
      ...> |> State.add_to_hand(:player1, Card.create(%{name: "Imp"}, id: :card1))
      ...> |> State.add_to_hand(:player1, Card.create(%{name: "Imp"}, id: :card2))
      ...> |> State.remove_from_hand(:player1, :card1)
      ...> |> State.get_hand(:player1)
      ...> |> Enum.map(&Entity.get(&1, :id))
      [:card2]
  """
  def remove_from_hand(%__MODULE__{} = state, player_id, card_id) do
    update_player(state, player_id, fn m ->
      Map.update!(m, :hand, fn cards ->
        index = Enum.find_index cards, &(Entity.get(&1, :id) == card_id)
        List.delete_at cards, index
      end)
    end)
  end

  @doc """
  Updates the player with the given id.

      iex> State.create
      ...> |> State.update_player(:player1, fn(p) -> %{p | deck: ["x"]} end)
      ...> |> State.get_player(:player1)
      %{Player.create(:player1) | deck: ["x"]}
  """
  def update_player(%__MODULE__{} = state, player_id, func) do
    with_player_id =
      fn :get_and_update, list, next_op ->
        index = Enum.find_index(list, &(Map.get(&1, :id) == player_id))
        item = Enum.at(list, index)

        {_, updated_item} = next_op.(item)
        {item, List.replace_at(list, index, updated_item)}
      end

    update_in(state, [Access.key(:players), with_player_id], func)
  end

end