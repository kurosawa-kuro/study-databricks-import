# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## このリポジトリの目的

**Databricks Free Edition のみ** を前提に、`SQL Warehouse` 接続 → `Managed Volume` 作成 → `Files API` upload → `read_files()` → `CREATE OR REFRESH MATERIALIZED VIEW` という **standalone pipeline** をローカルから通す学習リポジトリ。

前提にしない (= コードを書くときに想定してはいけない): Free Trial / 有償 workspace / 管理者権限 / Databricks Connect / GCS external location・external volume。catalog は常に `workspace` 固定 (Free Edition の制約)。

## 必須: doppler 経由で実行する

すべての `make` target は秘密 (`DWH_DATABRICKS_TOKEN` 等) を環境変数から読む。secret は doppler で注入するため、コマンドは必ず `doppler run --` を前置する。

```bash
doppler setup --project kuro-dev-k --config dev --no-interactive   # 初回のみ
doppler run -- make sql-test
```

`doppler run --` を付けずに `make sql-test` を直接叩くと token 未設定で `exit 2` になる。

## セットアップ & 主要コマンド

```bash
make install          # .venv 作成 + pip install -e .  (doppler 不要)

doppler run -- make sql-test        # SELECT 1 (疎通確認)
doppler run -- make sql-catalog     # current_catalog() → workspace
doppler run -- make sql-values      # customers/orders を VALUES で作り JOIN 集計
doppler run -- make volume-create   # Managed Volume workspace.default.raw_logs 作成
doppler run -- make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json
doppler run -- make pipeline-create # read_files → materialized view 作成
doppler run -- make pipeline-verify # row_count 確認 (期待値 3)
doppler run -- make volume-clean    # MV と Volume を drop (後片付け)

# 任意 SQL を1文流す
doppler run -- make sql-query QUERY="SELECT 42 AS answer"
```

テストフレームワークや lint は未導入。検証は上記 `make` target の手動実行で行う。

## アーキテクチャ (big picture)

全 target は **2 本の経路** のどちらかに落ちる:

1. **SQL 経路** — `Makefile` → `scripts/databricks_sql_test.sh` → `src/study_databricks_import/sql_connectivity.py`。
   `databricks-sql-connector` で SQL Warehouse に接続し SQL を実行する。`DATABRICKS_TOKEN` (= `DWH_DATABRICKS_TOKEN`) を使う。`sql-test`/`sql-catalog`/`sql-values`/`volume-create`/`volume-clean`/`pipeline-create`/`pipeline-verify`/`sql-query` がこれ。
2. **Files API 経路** — `Makefile` → `scripts/databricks_volume_upload.sh`。
   `curl` で `PUT /api/2.0/fs/files{VOLUME_PATH}` を叩いてローカルファイルを Volume に upload する。`DATABRICKS_FILES_TOKEN` を使う。`volume-upload` のみがこれ。

`sql_connectivity.py` の引数で挙動が決まる:
- `--mode query|catalog|values` … 定義済みフロー
- `--sql-file <path>` … `.sql` を `;` で分割して順次実行 (volume/pipeline 系 target はこれ経由で `databricks/sql/**/*.sql` を流す)
- `--query "<SQL>"` … 単発 SQL

### トークンの scope に注意

`DWH_DATABRICKS_TOKEN` は **`sql, files` の両 scope** を持つ scoped PAT である必要がある。`Makefile` 内で:
- `DATABRICKS_TOKEN` = `DWH_DATABRICKS_TOKEN`
- `DATABRICKS_FILES_TOKEN` = `DWH_DATABRICKS_FILES_TOKEN` があればそれ、無ければ `DWH_DATABRICKS_TOKEN` に fallback

upload (`files` scope) が 403 等で失敗する場合、token の scope を疑う。

### 接続先のデフォルト値

`Makefile` 冒頭に hostname / http_path がハードコードされている (`?=` なので env で上書き可)。別 workspace を使うなら `DATABRICKS_SERVER_HOSTNAME` / `DATABRICKS_HTTP_PATH` を渡す。

## SQL の定義場所と重複に注意

実行される SQL は `databricks/sql/{foundation,volume,pipeline}/*.sql` に置く。

ただし `--mode values` の SQL は `sql_connectivity.py` 内 `DEFAULT_VALUES_STATEMENTS` にも **二重定義** されている (`foundation/03_values_seed.sql` と同内容)。`sql-values` のスキーマ/データを変えるときは両方を直す必要がある。

## ディレクトリ

```text
src/study_databricks_import/sql_connectivity.py   # SQL 経路の本体 (CLI)
scripts/databricks_sql_test.sh                    # SQL 経路の薄い wrapper
scripts/databricks_volume_upload.sh               # Files API 経路 (curl)
databricks/sql/                                   # 実行対象 SQL (foundation/volume/pipeline)
data/                                             # 参照用 fixture (events.json 等)。維持する
docs/                                             # 確定スコープ / 検証記録 / 技術的債務
```

`docs/01_confirmed_scope.md` (確定スコープ) と `docs/03_technical_debt.md` (未対応: GCS 取得・Cloud Run Job 連携・streaming table 化・差分取り込み等) を、スコープ判断の根拠として参照する。

## 言語

ドキュメント・コミットメッセージは日本語が canonical。コード内 identifier は英語。
