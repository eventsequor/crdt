defmodule Chat do
  alias Cluster.NodeCluster

  def insert(msg) when is_bitstring(msg) do
    Crdt.TreeDoc.insert(get_pos_id(), msg)
  end

  def insert({pos_id, message}) when is_number(pos_id) do
    Crdt.TreeDoc.insert(get_pos_id(pos_id), message)
  end

  def insert({pos_id, message}) when is_number(pos_id) == false do
    Crdt.TreeDoc.insert(pos_id, message)
  end

  def insert(pos_id, message) when is_number(pos_id) do
    Crdt.TreeDoc.insert(get_pos_id(pos_id), message)
  end

  def insert(pos_id, message) when is_number(pos_id) == false do
    Crdt.TreeDoc.insert(pos_id, message)
  end

  def delete(pos_id) do
    Crdt.TreeDoc.delete(pos_id)
  end

  def print_all_messages do
    Crdt.TreeDoc.print_all()
  end

  def print_actual do
    Crdt.TreeDoc.print_actual()
  end

  def new_message(message) do
    {get_pos_id(), message}
  end

  defp get_pos_id(pos_id \\ nil) do
    node_name = NodeCluster.get_name_node()

    if pos_id == nil do
      pos_id = :os.system_time(:millisecond)
      "#{pos_id}_#{node_name}"
    else
      if is_number(pos_id), do: "#{pos_id}_#{node_name}", else: pos_id
    end
  end
end
