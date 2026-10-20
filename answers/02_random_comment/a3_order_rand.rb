# よく紹介される書き方: DB 側でランダムに並べ替えて1件取る
# 書き方は短いが、全件に乱数を振ってから一番小さいものを選ぶので、最低でも全件ぶん O(n) かかる
def solve(board_id)
  Comment.where(board_id: board_id).order(Arel.sql("RAND()")).first
end
