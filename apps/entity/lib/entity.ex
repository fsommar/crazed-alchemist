defmodule Entity do
  defstruct [:id, :name, :owner, buffs: []]

  @doc """
  Returns the id of the provided entity.

    iex> Entity.id(%{:entity => %Entity{id: "e1"}})
    "e1"

    iex> Entity.id(%{:entity => %Entity{name: "ent"}})
    nil
  """
  def id(entity) do
    entity
    |> Map.get(:entity)
    |> Map.get(:id)
  end

  @doc """
  Returns the name of the provided entity.

    iex> Entity.name(%{:entity => %Entity{name: "Hello World"}})
    "Hello World"

    iex> Entity.name(%{:entity => %Entity{id: "e1"}})
    nil
  """
  def name(entity) do
    entity
    |> Map.get(:entity)
    |> Map.get(:name)
  end

  @doc """
  Returns the owner id of the provided entity.

    iex> Entity.owner(%{:entity => %Entity{owner: "p1"}})
    "p1"

    iex> Entity.owner(%{:entity => %Entity{id: "e1"}})
    nil
  """
  def owner(entity) do
    entity
    |> Map.get(:entity)
    |> Map.get(:owner)
  end

  defmacro __using__(_) do
    quote do

    end
  end
end