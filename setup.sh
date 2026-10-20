#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker が見つかりません。Docker Desktop をインストールしてから、もう一度実行してください。"
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "Docker が起動していません。Docker Desktop を起動してから、もう一度実行してください。"
  exit 1
fi

SCALE="${SCALE:-1m}"

echo "==> コンテナを起動しています（初回は数分かかります）"
docker compose up -d --build --wait

echo "==> データを作成しています（SCALE=${SCALE}）"
docker compose exec -T -e SCALE="${SCALE}" app ruby lib/setup_db.rb

chmod +x bin/*

cat <<'MSG'

セットアップが完了しました！

  bin/run 00     お題を実行して計測する
  bin/try 00     自分のコードを書くファイルを作る
  bin/console    ActiveRecord を自由に試す

MSG
