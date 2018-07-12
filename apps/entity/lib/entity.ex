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

  def get(map) do
    Map.get(map, :entity)
  end

  def get(map, key) do
    cond do
      Map.has_key? map, key -> Map.get(map, key)
      Entity.has_key? key   -> get(map) |> Map.get(key)
      true                  -> nil
    end
  end

  def get_attack(map) do
    Entity.get(map, :name)
    |> Data.get_definition()
    |> Map.get(:attack)
  end

  def update!(entity, key, func) do
    case update(entity, key, func) do
      nil -> raise "key #{inspect key} not found in entity #{entity.__struct__ |> Module.split() |> Enum.at(-1)}"
      map -> map
    end
  end

  def update(entity, key, func) do
    cond do
      Map.has_key? entity, key -> Map.update!(entity, key, func)
      Entity.has_key? key      -> Map.update!(entity, :entity, &Map.update!(&1, key, func))
      true                     -> nil
    end
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
    Enum.reduce(opts, entity, fn {key, val}, acc ->
      update(acc, key, fn _ -> val end) || acc
    end)
  end

  defmacro __using__(_) do
    quote do

      @doc """
      Creates an entity, optionally with a list of keyword arguments, given a map with a `:name` key.
      """
      def create(%{name: name} = _entity, opts \\ []) do
        Entity.apply_opts %__MODULE__{}, opts ++ [name: name]
      end

    end
  end
end