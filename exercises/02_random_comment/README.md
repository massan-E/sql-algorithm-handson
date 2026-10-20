# お題02: 掲示板についたコメントからランダムに1件取り出す

X（旧Twitter）のポストへの返信から1件をランダムに選ぶような機能です。

`solve(board_id)` が、その掲示板についたコメントの中からランダムに1件を返すようにしてください。計測は掲示板2で行います。

次の3つを満たすと「OK」になります。

- 掲示板2のコメントが返ってくる
- コメントが0件の掲示板1では `nil` を返す（エラーにしない）
- 何回か実行したときに、毎回同じコメントにならない

`baseline.rb` の `sample` は、Ruby の配列から1つをランダムに選ぶメソッドです。
動きはしますが、「1件だけほしい」のに何をしているでしょうか？

```bash
bin/run 02           # 計測する
bin/run 02 --sql     # 発行されたSQLも表示する
bin/try 02           # 自分のコードを書くファイルを作る
bin/console          # ActiveRecord を自由に試す（Comment.where(board_id: 2).explain なども使えます）
```

## テーブル

```text
comments
  id, user_id, board_id, body, created_at, updated_at,
  condition（0: 公開, 1: 非表示）, is_read（既読なら true）

インデックス: board_id, user_id
```

コメントの id は、掲示板2のものと他の掲示板のものが混ざった順番で振られています。
