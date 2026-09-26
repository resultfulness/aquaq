import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn solve(input: String) -> Result(String, String) {
  let map =
    dict.from_list([
      #(0, " "),
      #(1, ""),
      #(2, "abc"),
      #(3, "def"),
      #(4, "ghi"),
      #(5, "jkl"),
      #(6, "mno"),
      #(7, "pqrs"),
      #(8, "tuv"),
      #(9, "wxyz"),
    ])

  use chars <- result.try(
    string.split(input, "\n")
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.try_map(fn(line) {
      use nums <- result.try(
        string.split(line, " ")
        |> list.try_map(int.parse)
        |> result.map_error(fn(_) { "couldn't parse input as number: " <> line }),
      )

      case nums {
        [key, presses] if presses > 0 -> {
          use key_str <- result.try(
            dict.get(map, key)
            |> result.map_error(fn(_) { "invalid key: " <> line }),
          )

          string.drop_start(key_str, presses - 1)
          |> string.first()
          |> result.map_error(fn(_) { "invalid press count: " <> line })
        }
        _ -> Error("invalid line: " <> line)
      }
    }),
  )

  Ok(string.join(chars, ""))
}
