defmodule Crdt.Reply do
  alias Cluster.TaskCall
  alias Cluster.LoadBalancer
  use GenServer

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok)
  end

  # Server (callbacks)

  @impl true
  def init(:ok) do
    pid = spawn_link(Crdt.Reply, :reply_message, [])
    {:ok, pid}
  end

  def reply_message(
        number_of_message \\ 0,
        number_of_clusters \\ 0,
        number_of_message_delete \\ 0
      ) do
    Process.sleep(500)
    message = Crdt.TreeDoc.get_tree_doc()
    actual_number_nodes = Enum.count(Cluster.LoadBalancer.get_node_lists())
    actual_number_message = Enum.count(message)

    actual_number_message_deleted =
      if Enum.count(message) > 0 do
        Enum.reduce(message, 0, fn msg, acc ->
          if elem(msg, 1) |> elem(0) == :delete, do: acc + 1, else: acc + 0
        end)
      else
        0
      end

    #
    if number_of_message != actual_number_message or number_of_clusters != actual_number_nodes or
         number_of_message_delete != actual_number_message_deleted do
      LoadBalancer.get_node_lists()
      |> Enum.each(fn node ->
        Enum.each(message, fn {pos_id, {status, message}} ->
          TaskCall.run_spawn(node, Chat, :insert, [{pos_id, message}])

          if status == :delete do
            TaskCall.run_spawn(node, Chat, :delete, [pos_id])
          end
        end)
      end)
    end

    reply_message(actual_number_message, actual_number_nodes, actual_number_message_deleted)
  end
end
