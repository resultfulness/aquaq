import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

fn win_rate(player_ranking: Float, opponent_ranking: Float) -> Float {
  1.0
  /. {
    1.0
    +. case float.power(10.0, { opponent_ranking -. player_ranking } /. 400.0) {
      Ok(v) -> v
      Error(_) -> panic as "hardcoded value can't fail"
    }
  }
}

fn points(win_rate: Float) -> Float {
  20.0 *. { 1.0 -. win_rate }
}

fn update_ratings(
  player_ranking: Float,
  opponent_ranking: Float,
  did_player_win: Bool,
) -> #(Float, Float) {
  case did_player_win {
    True -> {
      let points = win_rate(player_ranking, opponent_ranking) |> points
      #(player_ranking +. points, opponent_ranking -. points)
    }
    False -> {
      let points = win_rate(opponent_ranking, player_ranking) |> points
      #(player_ranking -. points, opponent_ranking +. points)
    }
  }
}

pub fn solve(input: String) -> Result(String, String) {
  use rankings <- result.try(
    string.split(input, "\n")
    |> list.drop(1)
    |> list.try_fold(dict.new(), fn(rankings, row) {
      use #(player_a, player_b, score) <- result.try(
        case string.split(row, ",") {
          [player_a, player_b, score] -> Ok(#(player_a, player_b, score))
          _ -> Error("invalid input")
        },
      )

      let a_ranking = dict.get(rankings, player_a) |> result.unwrap(1200.0)
      let b_ranking = dict.get(rankings, player_b) |> result.unwrap(1200.0)

      use did_a_win <- result.try(
        string.split(score, "-")
        |> list.try_map(int.parse)
        |> fn(x) {
          case x {
            Ok([a_score, b_score]) -> Ok(a_score > b_score)
            _ -> Error("invalid input")
          }
        },
      )

      let #(new_a_ranking, new_b_ranking) =
        update_ratings(a_ranking, b_ranking, did_a_win)

      Ok(
        rankings
        |> dict.insert(player_a, new_a_ranking)
        |> dict.insert(player_b, new_b_ranking),
      )
    }),
  )

  let all_elos = dict.to_list(rankings) |> list.map(fn(a) { a.1 })
  use max_elo <- result.try(
    list.max(all_elos, float.compare)
    |> result.map(float.truncate)
    |> result.map_error(fn(_) { "rankings empty" }),
  )
  use min_elo <- result.try(
    list.max(all_elos, order.reverse(float.compare))
    |> result.map(float.truncate)
    |> result.map_error(fn(_) { "rankings empty" }),
  )

  Ok({ max_elo - min_elo } |> int.to_string)
}
