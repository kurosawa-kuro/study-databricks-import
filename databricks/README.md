# Databricks README

## 位置づけ

Databricks 配下のファイル一覧と、主導線で使う SQL / notebook の置き場をまとめる。

## 主導線

1. `sql-test`
2. `sql-catalog`
3. `volume-create`
4. `volume-upload`
5. `pipeline-create`
6. `pipeline-verify`

## コマンド

```bash
doppler run -- make sql-test
doppler run -- make sql-catalog
doppler run -- make sql-values
```

## SQL の中身

- `sql/foundation/`
  - [01_connectivity.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/foundation/01_connectivity.sql)
  - [02_catalog.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/foundation/02_catalog.sql)
  - [03_values_seed.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/foundation/03_values_seed.sql)
- `sql/volume/`
  - [01_create_managed_volume.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/volume/01_create_managed_volume.sql)
  - [02_drop_volume_artifacts.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/volume/02_drop_volume_artifacts.sql)
- `sql/pipeline/`
  - [01_create_events_pipeline_mv.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/pipeline/01_create_events_pipeline_mv.sql)
  - [02_verify_events_pipeline_mv.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/pipeline/02_verify_events_pipeline_mv.sql)

## 主なコマンド

```bash
doppler run -- make sql-test
doppler run -- make sql-catalog
doppler run -- make volume-create
doppler run -- make volume-upload \
  LOCAL_FILE=./data/events.json \
  VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json
doppler run -- make pipeline-create
doppler run -- make pipeline-verify
doppler run -- make volume-clean
```

詳細:

- 確定スコープ: [docs/01_confirmed_scope.md](/home/ubuntu/repos/study-databricks-import/docs/01_confirmed_scope.md)
- 検証記録: [docs/02_pipeline_validation.md](/home/ubuntu/repos/study-databricks-import/docs/02_pipeline_validation.md)
- 技術的債務: [docs/03_technical_debt.md](/home/ubuntu/repos/study-databricks-import/docs/03_technical_debt.md)
