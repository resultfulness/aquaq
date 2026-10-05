import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile

fn are_words_neighbours(word1: String, word2: String) -> Bool {
  let word1 = string.to_graphemes(word1)
  let word2 = string.to_graphemes(word2)

  are_words_neighbours_loop(word1, word2, 0)
}

fn are_words_neighbours_loop(
  word1: List(String),
  word2: List(String),
  fails: Int,
) -> Bool {
  case word1, word2 {
    _, _ if fails > 1 -> False
    [], [] if fails == 1 -> True
    [], _ -> False
    [_, ..], [] -> False
    [first1, ..rest1], [first2, ..rest2] ->
      are_words_neighbours_loop(rest1, rest2, case first1 == first2 {
        True -> fails
        False -> fails + 1
      })
  }
}

fn get_word_neighbours(
  word: String,
  words_by_length: Dict(Int, List(String)),
) -> List(String) {
  let length = string.length(word)
  let words = dict.get(words_by_length, length) |> result.unwrap([])

  list.filter(words, fn(x) { are_words_neighbours(word, x) })
}

fn find_shortest(
  start: String,
  end: String,
  words_by_length: Dict(Int, List(String)),
) -> Result(Int, Nil) {
  find_shortest_loop(start, end, dict.new(), words_by_length, dict.new())
}

fn compare_words(a: #(String, Int), b: #(String, Int)) {
  int.compare(a.1, b.1)
}

fn find_shortest_loop(
  current: String,
  end: String,
  distances: Dict(String, Int),
  words_by_length: Dict(Int, List(String)),
  visited: Dict(String, Nil),
) -> Result(Int, Nil) {
  case current == end {
    True -> dict.get(distances, end)
    False -> {
      let neighbours = get_word_neighbours(current, words_by_length)

      let new_distance =
        1 + { dict.get(distances, current) |> result.unwrap(1) }

      let distances =
        list.filter(neighbours, fn(n) { !dict.has_key(visited, n) })
        |> list.fold(distances, fn(distances, n) {
          dict.insert(distances, n, case dict.get(distances, n) {
            Ok(v) -> int.min(v, new_distance)
            Error(_) -> new_distance
          })
        })
        |> dict.delete(current)

      use new_current <- result.try(
        dict.to_list(distances)
        |> list.max(order.reverse(compare_words)),
      )

      find_shortest_loop(
        new_current.0,
        end,
        distances,
        words_by_length,
        dict.insert(visited, current, Nil),
      )
    }
  }
}

pub fn solve(input: String) -> Result(String, String) {
  use words <- result.try(
    simplifile.read("inputs/words.txt")
    |> result.map(string.remove_suffix(_, "\n"))
    |> result.map_error(fn(_) { "error opening challenge input" })
    |> result.map(string.split(_, "\n")),
  )

  use input_words <- result.try(
    string.split(input, "\n")
    |> list.try_map(fn(row) {
      case string.split(row, ",") {
        [start, end] -> Ok(#(start, end))
        _ -> Error("invalid input")
      }
    }),
  )

  let words_by_length =
    list.fold(words, dict.new(), fn(words_by_length, word) {
      let length = string.length(word)
      let existing = dict.get(words_by_length, length) |> result.unwrap([])
      dict.insert(words_by_length, length, [word, ..existing])
    })

  list.try_fold(input_words, 1, fn(acc, x) {
    let #(start, end) = x
    use shortest <- result.try(find_shortest(start, end, words_by_length))

    Ok(acc * shortest)
  })
  |> result.map(int.to_string)
  |> result.map_error(fn(_) { "no path found" })
}
