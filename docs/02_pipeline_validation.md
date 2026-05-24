# Pipeline 検証記録

## 検証対象

Databricks Free Edition で、`Managed Volume -> Files API -> read_files -> materialized view` の流れが成立するかを確認する。

## 実施済み

### 1. Managed Volume

```bash
doppler run -- make volume-create
```

確認結果:

- `CREATE VOLUME workspace.default.raw_logs`
- `SHOW VOLUMES IN workspace.default`

### 2. Files API upload

```bash
doppler run -- make volume-upload \
  LOCAL_FILE=./data/events.json \
  VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json
```

確認結果:

- `Upload succeeded: ./data/events.json -> /Volumes/workspace/default/raw_logs/sample.json`

### 3. SQL load

```bash
doppler run -- make volume-load
```

確認結果:

- `CREATE OR REPLACE TABLE workspace.default.events_from_volume AS SELECT * FROM read_files(...)`
- 3 rows loaded

### 4. Standalone pipeline

```bash
doppler run -- make pipeline-create
doppler run -- make pipeline-verify
```

確認結果:

- `CREATE OR REFRESH MATERIALIZED VIEW workspace.default.events_from_volume_mv AS SELECT * FROM read_files(...)`
- `SELECT COUNT(*) AS row_count FROM workspace.default.events_from_volume_mv`
- `row_count = 3`

## 補助経路

必要なら [databricks/notebooks/01_volume_json_to_delta.py](/home/ubuntu/repos/study-databricks-import/databricks/notebooks/01_volume_json_to_delta.py) を使えるが、主導線ではない。

## 関連 SQL

- [05_create_managed_volume.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/05_create_managed_volume.sql)
- [06_load_events_from_volume.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/06_load_events_from_volume.sql)
- [07_verify_events_from_volume.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/07_verify_events_from_volume.sql)
- [08_drop_volume_artifacts.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/08_drop_volume_artifacts.sql)
- [09_create_events_pipeline_mv.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/09_create_events_pipeline_mv.sql)
- [10_verify_events_pipeline_mv.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/10_verify_events_pipeline_mv.sql)
