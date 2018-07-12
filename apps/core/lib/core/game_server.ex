defmodule Core.GameServer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def stop(server) do
    GenServer.stop(server)
  end

  ## Exposed functions

  def get_state(server) do
    GenServer.call(server, :get)
  end

  def play_card(server, player_id, card_id, _position \\ nil, _target_id \\ nil) do
    GenServer.call(server, [:play_card, player_id, card_id])
  end

  def attack(server, player_id, minion_id, target_id) do
    GenServer.call(server, [:attack, player_id, minion_id, target_id])
  end

  def end_turn(server, player_id) do
    GenServer.call(server, [:end_turn, player_id])
  end

  ## Server callbacks

  @impl GenServer
  def init(:ok) do
    {:ok,
     Core.create_game([minions: starter_cards("p1")], minions: starter_cards("p2"))
     |> Core.start_game()}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call([fun | args], _from, state) do
    {:reply, :ok, apply(Core, fun, [state | args])}
  end

  ## Definitions

  defp starter_cards(prefix) do
    [
      "Imp",
      "War Golem",
      "Imp",
      "War Golem",
      "Imp"
    ]
    |> Enum.with_index()
    |> Enum.map(fn {name, i} -> Core.create_minion(name, id: String.to_atom("#{prefix}_#{i}")) end)
  end
end
