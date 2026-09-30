import argv
import challenge0
import challenge1
import challenge2
import challenge3
import challenge4
import challenge5
import challenge6
import challenge7
import challenge9
import gleam/dict
import gleam/io
import gleam/result
import gleam/string
import simplifile

fn get_input(challenge_index: String) -> Result(String, String) {
  simplifile.read("inputs/" <> challenge_index <> ".txt")
  |> result.map(string.remove_suffix(_, "\n"))
  |> result.map_error(fn(_) { "error opening challenge input" })
}

fn print_solution(
  solution_index: String,
  solver: fn(String) -> Result(String, String),
) -> Nil {
  case
    get_input(solution_index)
    |> result.try(solver)
  {
    Ok(solution) -> io.println(solution)
    Error(error) -> io.println_error("error: " <> error)
  }
}

pub fn main() -> Nil {
  let solvers =
    dict.from_list([
      #("0", challenge0.solve),
      #("1", challenge1.solve),
      #("2", challenge2.solve),
      #("3", challenge3.solve),
      #("4", challenge4.solve),
      #("5", challenge5.solve),
      #("6", challenge6.solve),
      #("7", challenge7.solve),
      #("9", challenge9.solve),
    ])

  case argv.load().arguments {
    [challenge_index] ->
      case dict.get(solvers, challenge_index) {
        Ok(solver) -> print_solution(challenge_index, solver)
        Error(_) -> io.println_error("no such challenge: " <> challenge_index)
      }
    _ -> io.println("usage: ./aquaq <challenge>")
  }
}
