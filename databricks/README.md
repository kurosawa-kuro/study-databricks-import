# Databricks README

## 最重要

このリポジトリの Databricks 学習は、**Databricks Free Edition だけ**を対象にする。

主導線は `SQL Warehouse` に対するローカル疎通確認であり、`Databricks Connect` や notebook は主導線にしない。

## 主導線

1. Free Edition にログインする
2. `SQL Warehouses` の `Connection details` を確認する
3. `sql` scope の PAT を作る
4. `DWH_DATABRICKS_TOKEN` を Doppler で管理する
5. `doppler run -- make sql-test` を実行する
6. `doppler run -- make sql-catalog` と `doppler run -- make sql-ctas` を実行する
7. `doppler run -- make sql-values` を実行する

## コマンド

```bash
doppler run -- make sql-test
doppler run -- make sql-catalog
doppler run -- make sql-ctas
doppler run -- make sql-values
```

## 確認済み実績

以下は実行成功を確認済み。

- `doppler run -- make sql-test`
- `doppler run -- make sql-catalog`
- `doppler run -- make sql-ctas`

確認済み結果:

- `SELECT 1 AS ok`
- `current_catalog() = workspace`
- `workspace.default.free_edition_sql_test` の CTAS 成功
- `SELECT * FROM workspace.default.free_edition_sql_test` で `Row(ok=1)` を確認
- `customers` / `orders` は SQL の `VALUES` で再現する仕様

このため、この README の主導線は **確認済み仕様** として扱う。

## SQL の中身

- [01_connectivity.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/01_connectivity.sql)
- [02_catalog.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/02_catalog.sql)
- [03_ctas.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/03_ctas.sql)
- [04_values_seed.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/04_values_seed.sql)
- [05_create_managed_volume.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/05_create_managed_volume.sql)

## 次段階の未検証候補

Free Edition での次段階候補として、以下を残す。

- Managed Volume 作成
- Files API で `/Volumes/...` へ upload
- notebook / serverless compute で volume を読む
- Delta Table 化

詳細は [docs/02_managed_volume_validation.md](/home/ubuntu/repos/study-databricks-import/docs/02_managed_volume_validation.md) を参照。
