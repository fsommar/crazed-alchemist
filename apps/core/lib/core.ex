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
      ...> |> Entity.get(:name)
      "Jaina Proudmoore"

      iex> Core.create_game([hero: Core.create_hero "Gul'dan"])
      ...> |> State.get_hero(:player1)
      ...> |> Entity.get(:name)
      "Gul'dan"

  If there's a need to only populate the second player, the first player can be provided an empty list `[]`.

      iex> Core.create_game([], [minions: [Core.create_minion("Imp"), Core.create_minion("War Golem", id: "wg-1")]])
      ...> |> State.get_minions(:player2)
      ...> |> Enum.count()
      2
  """
  def create_game(player1 \\ [], player2 \\ []) do
    # The optionals are passed to player creation, as they can e.g. read and act on the `:hero` key.
    state =
      State.create(Core.create_player(:player1, player1), Core.create_player(:player2, player2))

    # This takes care of adding minions, and cards to a player's deck and hand.
    Enum.reduce([player1: player1, player2: player2], state, fn {player_id, p}, state ->
      [minions: &State.place_minion/3, hand: &State.add_to_hand/3, deck: &State.add_to_deck/3]
      |> Enum.reduce(state, fn {key, func}, state ->
        Enum.reduce(Keyword.get(p, key, []), state, &func.(&2, player_id, &1))
      end)
    end)
  end

  def start_game(%State{} = state) do
    state
    |> (&Enum.reduce(1..4, &1, fn _, state -> draw_card(state, :player1) end)).()
    |> (&Enum.reduce(1..3, &1, fn _, state -> draw_card(state, :player2) end)).()
  end

  def create_player(player_id, opts \\ []) do
    State.Player.create(player_id, [hero: Core.create_hero("Jaina Proudmoore")] ++ opts)
  end

  def create_hero(name, opts \\ []) do
    Entity.Hero.create(Data.Hero.get(name), opts)
  end

  def create_minion(name, opts \\ []) do
    Entity.Minion.create(Data.Minion.get(name), opts)
  end

  def draw_card(%State{} = state, player_id) do
    case State.pop_deck(state, player_id) do
      {nil, state} ->
        State.update_hero(state, player_id, fn hero ->
          hero
          |> Entity.Attacker.damage(Entity.get(hero, :fatigue))
          |> Entity.update!(:fatigue, &(&1 + 1))
        end)

      {card, state} ->
        State.add_to_hand(state, player_id, card)
    end
  end

  def play_card(%State{} = state, player_id, card_id) do
    %Entity.Card{} = card = State.get_entity(state, player_id, card_id)
    minion = Entity.get(card, :name) |> create_minion(id: card_id)

    state
    |> State.remove_from_hand(player_id, card_id)
    |> State.place_minion(player_id, minion)
  end

  def end_turn(%State{player_in_turn: other_player_id} = state, player_id) do
    %State{state | player_in_turn: player_id}
    |> draw_card(other_player_id)
    |> draw_card(player_id)
  end

  def attack(%State{} = state, _player_id, minion_id, target_id) do
    attack_with = fn id ->
      &Entity.Attacker.damage(&1, Entity.get_attack(State.get_entity(state, id)))
    end

    state
    |> State.update_minion(target_id, attack_with.(minion_id))
    |> State.update_minion(minion_id, attack_with.(target_id))
  end

  def damage_hero(%State{} = state, player_id, amount) do
    State.update_hero(state, player_id, &Entity.Attacker.damage(&1, amount))
  end
end
