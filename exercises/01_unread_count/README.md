# お題01: 掲示板についた未読コメントの数を数える

`solve(board_id)` が、その掲示板についたコメントのうち未読（`is_read` が `false`）のものの件数を返すようにしてください。計測は掲示板2で行います。

`baseline.rb` は、掲示板のコメントを Ruby の `select` で絞り込んで数えています。
正しい数は出ますが、かなり遅いです。

- 何が遅いのか、`bin/run 01 --sql` で発行されたSQLを見て考えてみましょう。
- 「数えるだけ」なのに、何を取ってきているでしょうか？

```bash
bin/run 01           # 計測する
bin/run 01 --sql     # 発行されたSQLも表示する
bin/try 01           # 自分のコードを書くファイルを作る
```

## テーブル

```text
comments
  id, user_id, board_id, body, created_at, updated_at,
  condition（0: 公開, 1: 非表示）, is_read（既読なら true）
```
