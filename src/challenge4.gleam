import gleam/int
import gleam/list
import gleam/result

fn find_factors(up_to: Int) -> List(Int) {
  find_factors_loop(2, up_to, [])
}

fn find_factors_loop(x: Int, up_to: Int, factors: List(Int)) -> List(Int) {
  case x {
    final if final == up_to -> factors
    x ->
      find_factors_loop(x + 1, up_to, case x {
        factor if up_to % factor == 0 -> [factor, ..factors]
        _ -> factors
      })
  }
}

fn have_common_factor(a: Int, factors: List(Int)) -> Bool {
  case factors {
    [] -> False
    [first, ..] if a % first == 0 -> True
    [_, ..rest] -> have_common_factor(a, rest)
  }
}

fn find_coprimes(of: Int) -> List(Int) {
  let factors = find_factors(of)
  find_coprimes_loop(1, of, factors, [])
}

fn find_coprimes_loop(
  i: Int,
  up_to: Int,
  factors: List(Int),
  coprimes: List(Int),
) {
  case i {
    final if final == up_to -> coprimes
    _ ->
      find_coprimes_loop(
        i + 1,
        up_to,
        factors,
        case have_common_factor(i, factors) {
          True -> coprimes
          False -> [i, ..coprimes]
        },
      )
  }
}

pub fn solve(input: String) -> Result(String, String) {
  use num <- result.try(
    int.parse(input)
    |> result.map_error(fn(_) { "input not an integer" }),
  )

  Ok(
    find_coprimes(num)
    |> list.fold(0, fn(acc, x) { acc + x })
    |> int.to_string,
  )
}
