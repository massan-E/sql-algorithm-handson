# count は SELECT COUNT(*) になり、数えるところまで DB がやって数字だけ返してくれる
def solve(board_id)
  Comment.where(board_id: board_id, is_read: false).count
end
