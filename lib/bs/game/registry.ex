defmodule Bs.Game.Registry do
  alias Bs.Game.Supervisor
  alias Bs.GameState
  alias BsWeb.GameForm

  @name __MODULE__

  @type key :: Registry.key
  @type value :: Registry.value
  @type initializer :: key | GameState.t | GameForm.t

  @spec via(key) :: GenServer.name
  def via(id), do: {:via, Registry, {@name, id}}

  @spec options(key) :: GenServer.options
  def options(id), do: [name: via(id)]

  @spec create(key) :: {:ok, pid} | :error
  def create(id) when is_binary(id) do
    create(id, id)
  end

  @spec create(initializer, key) :: {:ok, pid} | :error
  def create(state, id)
  when is_binary(id)
  and is_map(state)
  do
    Supervisor.start_game_server([state, options(id)])
  end

  def create(fun, id) when is_function(fun) do
    create(fun.(), id)
  end

  def create(_state, id) do
    raise """
    Expected id to a be a binary. id: #{inspect id}
    """
  end

  @spec lookup(key) :: [{pid(), value}]
  def lookup(id) do
    Registry.lookup(@name, id)
  end

  @spec find(key) :: {:ok, pid} | :error
  def find(id) do
    case Registry.lookup(@name, id) do
      [{pid, _}] ->
        {:ok, pid}
      _ ->
        :error
    end
  end

  @spec lookup_or_create(key) :: {:ok, pid} | :error
  def lookup_or_create(id) when is_binary(id) do
    lookup_or_create(id, id)
  end

  @spec lookup_or_create(initializer, key) :: {:ok, pid} | :error
  def lookup_or_create(state, id) when is_binary(id) do
    case lookup(id) do
      [{pid, _}] ->
        {:ok , pid}
      _ ->
        create(state, id)
    end
  end
end
