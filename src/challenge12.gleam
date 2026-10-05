import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Direction {
  Up
  Down
}

fn flip_direction(direction: Direction) -> Direction {
  case direction {
    Up -> Down
    Down -> Up
  }
}

fn handle_floors(
  floors: Dict(Int, #(Int, Int)),
  current: Int,
  visits: Int,
  direction: Direction,
) -> Int {
  case dict.get(floors, current) {
    Error(_) -> visits
    Ok(#(do_reverse, how_far)) -> {
      let direction = case do_reverse {
        0 -> flip_direction(direction)
        _ -> direction
      }

      handle_floors(
        floors,
        case direction {
          Up -> current + how_far
          Down -> current - how_far
        },
        visits + 1,
        direction,
      )
    }
  }
}

pub fn solve(input: String) -> Result(String, String) {
  use rows <- result.try(
    string.split(input, "\n")
    |> list.try_map(fn(row) {
      case
        string.split(row, " ")
        |> list.try_map(int.parse)
      {
        Ok([do_reverse, how_far]) -> Ok(#(do_reverse, how_far))
        _ -> Error("invalid input")
      }
    }),
  )

  let floors =
    list.index_fold(rows, dict.new(), fn(floors, x, i) {
      dict.insert(floors, i, x)
    })

  Ok(handle_floors(floors, 0, 1, Up) |> int.to_string)
}
