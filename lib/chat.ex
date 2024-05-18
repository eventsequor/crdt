defmodule Chat do
  def insert(msg) when is_bitstring(msg) do
    Crdt.TreeDoc.insert(:os.system_time(:millisecond), msg)
  end

  def insert({pos_id, message}) do
    Crdt.TreeDoc.insert(pos_id, message)
  end

  def insert(pos_id, message) do
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
    {:os.system_time(:millisecond), message}
  end
end
