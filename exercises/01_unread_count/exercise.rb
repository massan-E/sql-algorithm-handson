expected = Hash.new { |cache, board_id| cache[board_id] = Comment.where(board_id: board_id, is_read: false).count }

{
  title: "掲示板についた未読コメントの数を数える",
  uses_db: true,
  cases: [
    { label: "掲示板2", args: [2], check: ->(r) { r == expected[2] || "#{expected[2]} 件のはずが #{r.inspect} になっています" } },
    { label: "コメント0件の掲示板1", args: [1], check: ->(r) { r == 0 || "0 のはずが #{r.inspect} になっています" } },
  ],
}
