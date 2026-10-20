# 絞り込みは SQL の WHERE になったが、length は全件を Ruby に取ってきてから数えるので、まだ遅い
def solve(board_id)
  Comment.where(board_id: board_id, is_read: false).length
end
