import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Position {
  Position(row: Int, col: Int)
}

fn get_position_after_move(
  position: Position,
  direction: String,
) -> Result(Position, String) {
  case direction {
    "U" -> Ok(Position(position.row - 1, position.col))
    "D" -> Ok(Position(position.row + 1, position.col))
    "L" -> Ok(Position(position.row, position.col - 1))
    "R" -> Ok(Position(position.row, position.col + 1))
    invalid -> Error(invalid)
  }
}

fn ipairs(list: List(a)) -> List(#(Int, a)) {
  list.index_map(list, fn(x, i) { #(i, x) })
}

pub fn solve(input: String) -> Result(String, String) {
  let room =
    "  ##
 ####
######
######
 ####
  ##"

  let room_legal_indexes =
    string.split(room, "\n")
    |> list.map(fn(s) {
      string.to_graphemes(s)
      |> ipairs
      |> list.filter(fn(x) { x.1 == "#" })
      |> dict.from_list
    })
    |> ipairs
    |> dict.from_list

  let initial_position = Position(0, 2)

  use #(sum, _final_position) <- result.try(
    string.to_graphemes(input)
    |> list.try_fold(#(0, initial_position), fn(acc, direction) {
      let #(sum, previous_position) = acc

      use position_after_move <- result.try(get_position_after_move(
        previous_position,
        direction,
      ))

      let is_move_legal =
        dict.get(room_legal_indexes, position_after_move.row)
        |> result.try(dict.get(_, position_after_move.col))
        |> result.is_ok

      let next_position = case is_move_legal {
        True -> position_after_move
        False -> previous_position
      }

      Ok(#(sum + next_position.row + next_position.col, next_position))
    })
    |> result.map_error(fn(d) { "invalid direction: " <> d }),
  )

  Ok(int.to_string(sum))
}
