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
    get(map)
    |> Map.get(key)
  end

  def update!(map, key, val) do
    Map.update!(map, :entity, &Map.put(&1, key, val))
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
        Entity.has_key? key      -> Entity.update!(acc, key, val)
        true                     -> acc
      end
    end)
  end

  defmacro __using__(_) do
    quote do

      @doc """
      Creates an entity, optionally with a list of keyword arguments, given a map with a `:name` key.
      """
      def create(%{name: name} = _hero, opts \\ []) do
        Entity.apply_opts %__MODULE__{}, opts ++ [name: name]
      end

    end
  end
end