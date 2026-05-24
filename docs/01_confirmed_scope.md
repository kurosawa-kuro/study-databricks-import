# 確定スコープ

## 対象

- Databricks Free Edition のみ
- Serverless SQL Warehouse
- Managed Volume
- Files API
- Databricks SQL の standalone pipeline

## 非対象

- Databricks Free Trial
- 有償 workspace
- Databricks Connect 主導の開発
- GCS external location / external volume
- 管理者権限前提の構成

## 確認済みルート

1. `SQL Warehouse` 接続
2. `Managed Volume` 作成
3. `Files API` upload
4. `read_files('/Volumes/...')`
5. `CREATE OR REFRESH MATERIALIZED VIEW`
6. SQL 確認

## 確認済みコマンド

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

## 確認済み結果

- `current_catalog() = workspace`
- `workspace.default.customers`
- `workspace.default.orders`
- `workspace.default.raw_logs`
- `workspace.default.events_from_volume`
- `workspace.default.events_from_volume_mv`
- `row_count = 3`
