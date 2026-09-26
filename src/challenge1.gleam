import gleam/list
import gleam/string

const hex_alphabet = "0123456789abcdefABCDEF"

fn zero_out_non_hex(char: String) -> String {
  case string.contains(hex_alphabet, char) {
    True -> char
    False -> "0"
  }
}

pub fn solve(input: String) -> Result(String, String) {
  let input_length = string.length(input)
  let goto_length = input_length + 3 - input_length % 3

  let transformed =
    string.to_graphemes(input)
    |> list.map(zero_out_non_hex)
    |> string.join("")
    |> string.pad_end(goto_length, "0")

  let chunk_length = goto_length / 3

  Ok(
    string.concat([
      string.slice(transformed, 0, 2),
      string.slice(transformed, chunk_length, 2),
      string.slice(transformed, 2 * chunk_length, 2),
    ]),
  )
}
