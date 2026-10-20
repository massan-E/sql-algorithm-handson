# お題03: 掲示板ごとのコメント数を数える
#
# 仮説（どう書いたら速くなりそうか、なぜそう思ったか）:
#
#
# 結果メモ（実行してみてどうだったか）:
#
#
def solve(board_ids)
  Comment.where(board_id: board_ids).to_a.group_by(&:board_id).transform_values(&:size)
end
