expected = Hash.new { |cache, ids| cache[ids] = Comment.where(board_id: ids).group(:board_id).count }
ids = (2..11).to_a

{
  title: "【追加問題】掲示板ごとのコメント数を数える",
  uses_db: true,
  cases: [
    { label: "掲示板2〜11", args: [ids], check: ->(r) { r == expected[ids] || "#{expected[ids].inspect.slice(0, 60)}... のはずが違う結果になっています" } },
    { label: "コメント0件の掲示板1", args: [[1]], check: ->(r) { r == {} || "{} のはずが #{r.inspect} になっています" } },
  ],
}
