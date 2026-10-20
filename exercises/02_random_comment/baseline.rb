# お題02: 掲示板についたコメントからランダムに1件取り出す
#
# 仮説（どう書いたら速くなりそうか、なぜそう思ったか）:
#
#
# 結果メモ（実行してみてどうだったか）:
#
#
def solve(board_id)
  Board.find(board_id).comments.sample
end
