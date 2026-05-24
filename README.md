# study-databricks-import

Databricks Free Edition だけを使って、`SQL Warehouse` と `Managed Volume` を起点に **standalone pipeline** を作る学習リポジトリ。

## 最重要前提

このリポジトリは **Databricks Free Edition のみ利用可能** という制約を前提にする。

前提にしないもの:

- Databricks Free Trial
- 有償 workspace
- 管理者権限のある通常環境
- Databricks Connect が確実に使える前提
- GCS external location / external volume

## 最終主導線

このリポジトリの主導線は、Databricks Free Edition 上で次を通すこと。

1. `SQL Warehouse` にローカルから接続する
2. `Managed Volume` を作る
3. `Files API` で JSON を `/Volumes/...` に upload する
4. `read_files('/Volumes/...')` を使う
5. `CREATE OR REFRESH MATERIALIZED VIEW` で **standalone pipeline** を作る
6. SQL で結果確認する

## 確認済み仕様

この repo では、以下を **実行確認済み**。

- `doppler run -- make sql-test`
- `doppler run -- make sql-catalog`
- `doppler run -- make sql-ctas`
- `doppler run -- make sql-values`
- `doppler run -- make volume-create`
- `doppler run -- make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json`
- `doppler run -- make volume-load`
- `doppler run -- make volume-verify`
- `doppler run -- make pipeline-create`
- `doppler run -- make pipeline-verify`

確認できたこと:

- `current_catalog() = workspace`
- `workspace.default.customers` と `workspace.default.orders` を SQL の `VALUES` で再現できる
- `workspace.default.raw_logs` の Managed Volume を作れる
- `./data/events.json` を `/Volumes/workspace/default/raw_logs/sample.json` に upload できる
- `read_files('/Volumes/workspace/default/raw_logs/sample.json', format => 'json', multiLine => true)` が通る
- `workspace.default.events_from_volume` を SQL で作れる
- `workspace.default.events_from_volume_mv` を **materialized view backed pipeline** として作れる
- `workspace.default.events_from_volume_mv` で `row_count = 3` を確認できる

## 最短手順

### 1. 依存

```bash
cd /home/ubuntu/repos/study-databricks-import
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

### 2. Databricks token

`DWH_DATABRICKS_TOKEN` には **`sql, files` scope** を持つ scoped PAT を使う。

```bash
doppler setup --project kuro-dev-k --config dev --no-interactive
```

### 3. 基本疎通

```bash
doppler run -- make sql-test
doppler run -- make sql-catalog
```

### 4. Standalone pipeline まで一気に確認

```bash
doppler run -- make volume-create
doppler run -- make volume-upload \
  LOCAL_FILE=./data/events.json \
  VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json
doppler run -- make pipeline-create
doppler run -- make pipeline-verify
```

必要なら中間確認:

```bash
doppler run -- make volume-load
doppler run -- make volume-verify
```

後片付け:

```bash
doppler run -- make volume-clean
```

## ディレクトリ

```text
study-databricks-import/
  data/
  databricks/
    notebooks/
    sql/
  docs/
  scripts/
  src/
```

## ドキュメント

- [docs/01_confirmed_scope.md](/home/ubuntu/repos/study-databricks-import/docs/01_confirmed_scope.md)
- [docs/02_pipeline_validation.md](/home/ubuntu/repos/study-databricks-import/docs/02_pipeline_validation.md)
- [docs/03_technical_debt.md](/home/ubuntu/repos/study-databricks-import/docs/03_technical_debt.md)
- [databricks/README.md](/home/ubuntu/repos/study-databricks-import/databricks/README.md)
