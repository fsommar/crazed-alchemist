defmodule Entity.Attacker do
  defstruct [damage_taken: 0, attacks_this_turn: 0]

  @doc """
  Updates the composed `:attacker` key of an Entity.

    iex> Attacker.update!(%{:attacker => %{:health => 5}}, :health, &(&1 + 5))
    %{:attacker => %{:health => 10}}
  """
  def update!(entity, key, func) do
    Map.update!(entity, :attacker, fn(e) -> Map.update!(e, key, func) end)
  end

  @doc """
  Damages the attacker entity by the given amount.

    iex> Attacker.damage(%{:attacker => %Attacker{}}, 3)
    %{:attacker => %Attacker{damage_taken: 3}}
  """
  def damage(entity, amount) do
    Entity.Attacker.update!(entity, :damage_taken, &(amount + &1))
  end

  defmacro __using__(_) do
    quote do

    end
  end
end