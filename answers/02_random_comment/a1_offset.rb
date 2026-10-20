# 記事の案2: 乱数ぶん飛ばして1件取る
# 全件は取ってこないが、OFFSET は DB が先頭から1件ずつ読み飛ばすので、後ろの方ほど遅くなる。O(n)
def solve(board_id)
  comments = Comment.where(board_id: board_id)
  count = comments.count
  return nil if count.zero?

  comments.offset(rand(count)).first
end
