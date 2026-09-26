import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn process(remaining: List(Int), processed: List(Int)) -> List(Int) {
  case remaining {
    [] -> processed
    [first, ..rest] ->
      process(rest, case list.contains(processed, first) {
        False -> [first, ..processed]
        True -> list.drop_while(processed, fn(x) { x != first })
      })
  }
}

pub fn solve(input: String) -> Result(String, String) {
  use values <- result.try(
    string.split(input, " ")
    |> list.try_map(int.parse)
    |> result.map_error(fn(_) { "non-integer found in input" }),
  )

  Ok(
    process(values, [])
    |> list.fold(0, fn(acc, x) { acc + x })
    |> int.to_string(),
  )
}
