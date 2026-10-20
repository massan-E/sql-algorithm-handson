{
  title: "1〜n の合計を求める",
  uses_db: false,
  cases: [
    { label: "n=10,000,000", args: [10_000_000], check: ->(r) { r == 50_000_005_000_000 || "#{r.inspect} になっています" } },
    { label: "n=1", args: [1], check: ->(r) { r == 1 || "n=1 で #{r.inspect} になっています" } },
  ],
}
