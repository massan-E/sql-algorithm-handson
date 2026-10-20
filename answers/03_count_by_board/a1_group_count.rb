# GROUP BY で、掲示板ごとに数えるところまで DB にやってもらう
def solve(board_ids)
  Comment.where(board_id: board_ids).group(:board_id).count
end
