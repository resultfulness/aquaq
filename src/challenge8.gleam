import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Milk {
  Milk(amount_left: Int, days_left: Int)
}

fn buy_milk(amount: Int) {
  Milk(amount, 5)
}

fn eat_milk(milk: Milk) {
  Milk(milk.amount_left - 100, milk.days_left)
}

fn age_milk(milk: Milk) {
  Milk(milk.amount_left, milk.days_left - 1)
}

fn is_milk_edible(milk: Milk) {
  milk.days_left > 0
}

pub fn solve(input: String) -> Result(String, String) {
  let initial_milk: List(Milk) = []

  use #(milk_left, cereal_left) <- result.try(
    string.split(input, "\n")
    |> list.drop(1)
    |> list.try_fold(#(initial_milk, 0), fn(acc, row) {
      use #(bought_milk, bought_cereal) <- result.try(
        string.split(row, ",")
        |> list.drop(1)
        |> list.try_map(int.parse)
        |> fn(values) {
          case values {
            Ok([bought_milk, bought_cereal]) -> {
              Ok(#(bought_milk, bought_cereal))
            }
            _ -> Error("invalid input")
          }
        },
      )

      let #(old_milk, old_cereal) = acc

      let available_cereal = old_cereal + bought_cereal

      let #(post_breakfast_milk, post_breakfast_cereal) = case old_milk {
        [oldest_milk, ..rest]
          if available_cereal >= 100 && oldest_milk.amount_left >= 100
        -> {
          #([eat_milk(oldest_milk), ..rest], available_cereal - 100)
        }
        _ -> #(old_milk, available_cereal)
      }

      let new_milk =
        post_breakfast_milk
        |> fn(milk) {
          case bought_milk {
            0 -> milk
            _ -> list.append(milk, [buy_milk(bought_milk)])
          }
        }
        |> list.filter(is_milk_edible)
        |> list.map(age_milk)
      let new_cereal = post_breakfast_cereal

      Ok(#(new_milk, new_cereal))
    }),
  )

  Ok(
    {
      cereal_left + list.fold(milk_left, 0, fn(acc, x) { acc + x.amount_left })
    }
    |> int.to_string,
  )
}
