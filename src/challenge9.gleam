import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn solve(input: String) -> Result(String, String) {
  use values <- result.try(
    string.split(input, "\n")
    |> list.try_map(int.parse)
    |> result.map_error(fn(_) { "non-integer found in input" }),
  )

  Ok(list.fold(values, 1, fn(acc, x) { acc * x }) |> int.to_string)
}
