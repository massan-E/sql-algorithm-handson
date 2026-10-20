# 記事の案3（記事の最終版）: id だけ集めてからランダムに選ぶ
# ActiveRecord のオブジェクトを作らず、インデックスだけで id が取れるので速い
# ただし id を全件集めるので、コメントが増えるほど遅くなる。O(n)
def solve(board_id)
  random_comment_id = Comment.where(board_id: board_id).pluck(:id).sample
  random_comment_id ? Comment.find(random_comment_id) : nil
end
