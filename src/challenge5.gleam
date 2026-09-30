import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

type Dice {
  Dice(front: Int, left: Int, top: Int)
}

fn rotate_dice(dice: Dice, direction: String) -> Result(Dice, String) {
  case direction {
    "U" -> Ok(Dice(7 - dice.top, dice.left, dice.front))
    "D" -> Ok(Dice(dice.top, dice.left, 7 - dice.front))
    "L" -> Ok(Dice(7 - dice.left, dice.front, dice.top))
    "R" -> Ok(Dice(dice.left, 7 - dice.front, dice.top))
    invalid -> Error(invalid)
  }
}

pub fn solve(input: String) -> Result(String, String) {
  let initial_dice1 = Dice(1, 2, 3)
  let initial_dice2 = Dice(1, 3, 2)

  use #(sum, _num_steps, _final_dice1, _final_dice2) <- result.try(
    string.to_graphemes(input)
    |> list.try_fold(#(0, 0, initial_dice1, initial_dice2), fn(acc, direction) {
      let #(sum, i, dice1, dice2) = acc

      use dice1 <- result.try(rotate_dice(dice1, direction))
      use dice2 <- result.try(rotate_dice(dice2, direction))

      let sum = case int.compare(dice1.front, dice2.front) {
        order.Eq -> sum + i
        _ -> sum
      }

      Ok(#(sum, i + 1, dice1, dice2))
    })
    |> result.map_error(fn(d) { "invalid direction: " <> d }),
  )

  Ok(sum |> int.to_string)
}
