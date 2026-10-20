{
  title: "掲示板についたコメントからランダムに1件取り出す",
  uses_db: true,
  cases: [
    {
      label: "掲示板2",
      args: [2],
      check: ->(r) { (r.is_a?(Comment) && r.board_id == 2) || "掲示板2のコメントではないもの（#{r.inspect.slice(0, 60)}）が返っています" },
    },
    {
      label: "コメント0件の掲示板1",
      args: [1],
      check: ->(r) { r.nil? || "コメントが0件の掲示板では nil を返してください" },
    },
    {
      label: "ランダム性",
      args: [2],
      repeat: 10,
      check: ->(rs) { rs.map { |c| c&.id }.uniq.size > 1 || "10回実行して毎回同じコメントが返っています" },
    },
  ],
}
