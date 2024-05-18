defmodule Crdt.TreeDoc do
  use GenServer
  @name_tree_doc TreeDoc

  # Callbacks
  def start_link(%{} = map) do
    GenServer.start_link(__MODULE__, map, name: @name_tree_doc)
  end

  @impl true
  def init(%{} = tree_doc) do
    {:ok, tree_doc}
  end

  @impl true
  def handle_cast({:insert, {pos_id, message}}, tree_doc) do
    {:noreply, Map.put_new(tree_doc, pos_id, {:active, message})}
  end

  @impl true
  def handle_cast({:delete, pos_id}, tree_doc) do
    tree_doc =
      case Map.get(tree_doc, pos_id) do
        {_state, message} -> Map.put(tree_doc, pos_id, {:delete, message})
        nil -> tree_doc
      end

    {:noreply, tree_doc}
  end

  @impl true
  def handle_cast({:reset}, _) do
    {:noreply, %{}}
  end

  @impl true
  def handle_call({:get}, _from, tree_doc) do
    {:reply, tree_doc, tree_doc}
  end

  def insert(pos_id, message) do
    GenServer.cast(@name_tree_doc, {:insert, {pos_id, message}})
  end

  def delete(pos_id) do
    GenServer.cast(@name_tree_doc, {:delete, pos_id})
  end

  def get_tree_doc do
    GenServer.call(@name_tree_doc, {:get})
  end

  def print_all do
    get_tree_doc()
    |> Enum.each(fn {pos_id, {_status, message}} ->
      IO.inspect("PosID: #{pos_id} - Message: #{message}")
    end)
  end

  def print_actual do
    get_tree_doc()
    |> Enum.each(fn {pos_id, {status, message}} ->
      if status == :active do
        IO.inspect("PosID: #{pos_id} - Message: #{message}")
      end
    end)
  end

  def reset do
    GenServer.cast(@name_tree_doc, {:reset})
  end
end
