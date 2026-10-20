# 記事の2年後の別解: id の最小〜最大から乱数を作り、それ以上で一番小さい id を取る
# インデックスを使って探すだけなので、件数が増えてもほぼ一瞬。O(log n)
# 弱点: id の間に大きな抜けがあると、抜けの直後のコメントが選ばれやすくなる（完全に均等なランダムではない）
def solve(board_id)
  comments = Comment.where(board_id: board_id)
  min_id, max_id = comments.pick(Arel.sql("MIN(id)"), Arel.sql("MAX(id)"))
  return nil unless min_id

  comments.where("id >= ?", rand(min_id..max_id)).order(:id).first
end
