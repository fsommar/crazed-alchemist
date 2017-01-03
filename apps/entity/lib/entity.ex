defmodule Entity do
  @keys [:id, :name, :owner, buffs: []]
  defstruct @keys

  @doc """
  Returns whether this key exists in the Entity struct.

    iex> Entity.has_key? :id
    true

    iex> Entity.has_key? :buffs
    true

    iex> Entity.has_key? :damage_taken
    false
  """
  def has_key?(key) do
    Enum.any? @keys, fn
      {k, _} -> k == key
      k      -> k == key
    end
  end

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

  @doc """
  Takes an Entity type struct and applies the provided keyword list to it.

    iex> Entity.apply_opts %Entity{id: "5", name: "Ent"}, buffs: [1, 2], owner: "p1"
    %Entity{id: "5", name: "Ent", buffs: [1, 2], owner: "p1"}

  Values are overwritten by the opts.

    iex> Entity.apply_opts %Entity{id: 1}, id: 3
    %Entity{id: 3}

  Non-existing keywords are ignored.

    iex> Entity.apply_opts %Entity{}, noexist: 15
    %Entity{}
  """
  def apply_opts(entity, opts) do
    opts
    |> Enum.reduce(entity, fn {key, val}, acc ->
      cond do
        Map.has_key? entity, key -> Map.put(acc, key, val)
        Entity.has_key? key      -> Map.update!(acc, :entity, &Map.put(&1, key, val))
        true                     -> acc
      end
    end)
  end

  defmacro __using__(_) do
    quote do

    end
  end
end