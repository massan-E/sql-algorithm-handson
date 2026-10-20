{
  title: "【追加問題】ユーザーが掲示板にコメントしたことがあるか調べる",
  uses_db: true,
  cases: [
    { label: "ユーザー5と掲示板2", args: [5, 2], check: ->(r) { r == true || "true のはずが #{r.inspect} になっています" } },
    { label: "コメント0件の掲示板1", args: [5, 1], check: ->(r) { r == false || "false のはずが #{r.inspect} になっています" } },
  ],
}
