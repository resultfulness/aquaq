import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn sum_combinations(number: Int) -> Int {
  sum_combinations_loop(0, [number, 0, 0], number)
}

fn sum_combinations_loop(
  sum: Int,
  combinations: List(Int),
  number: Int,
) -> Int {
  let sum =
    sum
    + {
      list.map(combinations, fn(x) { int.to_string(x) |> string.to_graphemes })
      |> list.fold(0, fn(acc, l) { acc + list.count(l, fn(s) { s == "1" }) })
    }

  case combinations {
    [0, 0, final] if final == number -> sum
    _ ->
      sum_combinations_loop(
        sum,
        case combinations {
          [0, b, a] -> [b - 1, 0, a + 1]
          [c, b, a] -> [c - 1, b + 1, a]
          _ -> panic
        },
        number,
      )
  }
}

pub fn solve(input: String) -> Result(String, String) {
  use number <- result.try(
    string.split(input, " numbers which sum to ")
    |> list.try_map(int.parse)
    |> fn(x) {
      case x {
        Ok([_, number]) -> Ok(number)
        _ -> Error("invalid input")
      }
    },
  )

  Ok(sum_combinations(number) |> int.to_string)
}
