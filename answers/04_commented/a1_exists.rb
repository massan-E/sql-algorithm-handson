# exists? は SELECT 1 ... LIMIT 1 になり、1件見つかった時点で探すのをやめる
def solve(user_id, board_id)
  Comment.exists?(user_id: user_id, board_id: board_id)
end
