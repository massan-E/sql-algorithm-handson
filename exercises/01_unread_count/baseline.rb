# お題01: 掲示板についた未読コメントの数を数える
#
# 仮説（どう書いたら速くなりそうか、なぜそう思ったか）:
#
#
# 結果メモ（実行してみてどうだったか）:
#
#
def solve(board_id)
  Board.find(board_id).comments.select { |comment| comment.is_read == false }.size
end
