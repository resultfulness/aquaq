import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

const int_max = 999

fn find_shortest(
  from: String,
  to: String,
  graph: Dict(String, Dict(String, Int)),
) {
  find_shortest_loop(from, to, graph, dict.new())
}

fn compare_nodes(a: #(String, Int), b: #(String, Int)) {
  int.compare(a.1, b.1)
}

fn find_shortest_loop(
  current: String,
  to: String,
  graph: Dict(String, Dict(String, Int)),
  distances: Dict(String, Int),
) {
  case current == to {
    True -> dict.get(distances, to)
    False -> {
      let updated_distances =
        update_distances(
          current,
          distances,
          dict.get(graph, current) |> result.unwrap(dict.new()),
        )

      use next_node <- result.try(
        dict.to_list(updated_distances)
        |> list.max(order.reverse(compare_nodes)),
      )

      find_shortest_loop(next_node.0, to, graph, updated_distances)
    }
  }
}

fn update_distances(
  current: String,
  distances: Dict(String, Int),
  nodes_adjacent_to_current: Dict(String, Int),
) -> Dict(String, Int) {
  dict.fold(nodes_adjacent_to_current, distances, fn(distances, to, cost) {
    update_distances_with_path(current, distances, to, cost)
  })
  |> dict.delete(current)
}

fn update_distances_with_path(
  current: String,
  distances: Dict(String, Int),
  to: String,
  cost: Int,
) {
  let current_distance = dict.get(distances, to) |> result.unwrap(int_max)
  let new_distance = cost + { dict.get(distances, current) |> result.unwrap(0) }
  case new_distance < current_distance {
    False -> distances
    True -> dict.insert(distances, to, new_distance)
  }
}

pub fn solve(input: String) -> Result(String, String) {
  use graph <- result.try(
    string.split(input, "\n")
    |> list.drop(1)
    |> list.try_fold(dict.new(), fn(weights, row) {
      use #(source, destination, cost) <- result.try(
        case string.split(row, ",") {
          [source, destination, cost] -> Ok(#(source, destination, cost))
          _ -> Error("invalid input")
        },
      )

      use cost <- result.try(
        int.parse(cost) |> result.map_error(fn(_) { "invalid input" }),
      )

      let source_adjacent_nodes =
        dict.get(weights, source) |> result.unwrap(dict.new())

      let destination_adjacent_nodes =
        dict.get(weights, destination) |> result.unwrap(dict.new())

      Ok(
        weights
        |> dict.insert(
          source,
          source_adjacent_nodes |> dict.insert(destination, cost),
        )
        |> dict.insert(
          destination,
          destination_adjacent_nodes |> dict.insert(source, cost),
        ),
      )
    }),
  )

  find_shortest("TUPAC", "DIDDY", graph)
  |> result.map(int.to_string)
  |> result.map_error(fn(_) { "no path found" })
}
