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
case "$SCALE" in
  1m) buffer_pool="512M" ;;
  10m)
    buffer_pool="2G"
    docker_memory="$(docker info --format '{{.MemTotal}}')"
    if [ "$docker_memory" -lt 8000000000 ]; then
      echo "注意: 1000万件には Docker に 8GB 以上のメモリが必要です（今は $(( docker_memory / 1024 / 1024 ))MB）。"
      echo "      Docker Desktop の Settings > Resources で Memory を増やしてください。"
    fi
    ;;
  *)
    echo "SCALE は 1m か 10m を指定してください（指定された値: ${SCALE}）"
    exit 1
    ;;
esac
echo "DB_BUFFER_POOL_SIZE=${buffer_pool}" > .env

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
