defmodule GraphUtils do


  @doc"""
  From wikipedia, a BFS is:

  1  procedure BFS(G,start_v):
  2      let Q be a queue
  3      label start_v as discovered
  4      Q.enqueue(start_v)
  5      while Q is not empty
  6          v = Q.dequeue()
  7          if v is the goal:
  8              return v
  9          for all edges from v to w in G.adjacentEdges(v) do
  10             if w is not labeled as discovered:
  11                 label w as discovered
  12                 w.parent = v
  13                 Q.enqueue(w)

  but the challenge is to accomplish this w/ recursion

  The data structures we'll need to keep around are a queue, a map of discovered nodes, the current path

  We can overload the last two as a single map, with the map being from node -> parent, where existing in
  the map indicates a node is discovered. The initial node with have a value of :start to indicate it has no parent

  We'll also take a function of v to return edges
  """
  def bfs(node, neighbors_fn) do
    queue = PriorityQueue.new() |> PriorityQueue.push(node, 1)
    discovered = Map.new() |> Map.put(node, :start)

    do_bfs(neighbors_fn, queue, discovered)
  end

  defp do_bfs(neighbors_fn, queue, discovered) do
    case PriorityQueue.pop(queue) do
      {:empty, _} -> {node, discovered}
      {{:value, v}, new_queue} ->
        {updated_queue, updated_discovered} = neighbors_fn.(v)
        |> Enum.reduce({new_queue, discovered}, fn w, {q, d} ->
          case Map.has_key?(d, w) do
            true -> {q, d}
            false -> {PriorityQueue.push(q, w, 1), Map.put(d, w, v)}
          end
        end)

        if :rand.uniform() > 0.9999 do
          updated_discovered |> get_path(v) |> length |> to_string |> IO.puts
        end

        do_bfs(neighbors_fn, updated_queue, updated_discovered)
    end
  end

  def get_path(map, goal) do
    get_path(map, goal, [])
  end

  defp get_path(map, current_node, path) do
    case Map.get(map, current_node) do
      nil -> path
      x -> get_path(map, x, [ current_node | path ])
    end
  end

end