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

## コマンド

```bash
doppler run -- make sql-test
doppler run -- make sql-catalog
doppler run -- make sql-ctas
```

## SQL の中身

- [01_connectivity.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/01_connectivity.sql)
- [02_catalog.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/02_catalog.sql)
- [03_ctas.sql](/home/ubuntu/repos/study-databricks-import/databricks/sql/03_ctas.sql)
