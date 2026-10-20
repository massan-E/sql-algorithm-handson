# お題04: ユーザーが掲示板にコメントしたことがあるか調べる
#
# 仮説（どう書いたら速くなりそうか、なぜそう思ったか）:
#
#
# 結果メモ（実行してみてどうだったか）:
#
#
def solve(user_id, board_id)
  Board.find(board_id).comments.any? { |comment| comment.user_id == user_id }
end
