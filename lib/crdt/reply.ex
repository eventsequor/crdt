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

  def reply_message do
    Process.sleep(10000)
    message = Crdt.TreeDoc.get_tree_doc()

    LoadBalancer.get_node_lists()
    |> Enum.each(fn node ->
      Enum.each(message, fn {pos_id, {_status, message}} ->
        TaskCall.run_sync_auto_detect(node, Chat, :insert, [{pos_id, message}])
      end)

      Enum.each(message, fn {pos_id, {status, _message}} ->
        if status == :delete do
          TaskCall.run_sync_auto_detect(node, Chat, :delete, [pos_id])
        end
      end)
    end)

    reply_message()
  end
end
