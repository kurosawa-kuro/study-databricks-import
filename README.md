# study-databricks-import

Databricks Free Edition だけを使い、ローカルから SQL Warehouse へ接続して疎通確認と最小 SQL 操作を学ぶための学習リポジトリ。

## 0. 最重要前提

このリポジトリは **Databricks Free Edition のみ利用可能** という制約を前提にする。

そのため、以下を前提にしない。

- Databricks Free Trial
- 有償 workspace
- 管理者権限のある通常環境
- Databricks Connect が確実に使える前提
- GCS external location / volume を簡単に使える前提

このリポジトリの Databricks 主導線は、**Serverless SQL Warehouse にローカルから接続して SQL を実行すること** である。

## 1. ゴール

まずは以下ができれば成功。

- Databricks Free Edition にログインできる
- SQL Warehouse の `Connection details` を取得できる
- ローカルから `SELECT 1` を実行できる
- `current_catalog()` を確認できる
- `CREATE TABLE AS SELECT` が通ることを確認できる

## 2. ディレクトリ構成

```text
study-databricks-import/
  README.md
  pyproject.toml
  .gitignore
  Makefile
  doppler.yaml
  data/
    customers.csv
    orders.csv
    events.json
    products.parquet
  databricks/
    README.md
    sql/
      01_connectivity.sql
      02_catalog.sql
      03_ctas.sql
  docs/
    01_goal.md
  scripts/
    databricks_sql_test.sh
  src/
    study_databricks_import/
      __init__.py
      sql_connectivity.py
```

## 3. Free Edition 確実ルート

### 3.1 依存を入れる

```bash
cd /home/ubuntu/repos/study-databricks-import
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

### 3.2 接続情報を取得する

Databricks Free Edition の `SQL Warehouses` から `Connection details` を開き、以下を控える。

- `Server hostname`
- `HTTP path`

さらに `sql` scope の Personal Access Token を作る。

### 3.3 Doppler を設定する

このリポジトリでは token を **人手で shell export しない**。

`doppler.yaml` では最低限、以下の secret を前提にする。

- `DWH_DATABRICKS_TOKEN`

`Server hostname` と `HTTP path` は、今の Free Edition 値を `Makefile` にデフォルトで持たせている。

初期化例:

```bash
doppler setup --project kuro-dev-k --config dev --no-interactive
```

### 3.4 依存を入れる

```bash
cd /home/ubuntu/repos/study-databricks-import
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

### 3.5 疎通確認

最初の成功確認はこれ。

```bash
doppler run -- make sql-test
```

または、Doppler を shell に inject 済みなら:

```bash
make sql-test
```

期待結果:

```text
Databricks SQL connectivity succeeded.
Query: SELECT 1 AS ok
Rows: [Row(ok=1)]
```

### 3.6 catalog 確認

```bash
doppler run -- make sql-catalog
```

期待例:

```text
Databricks SQL catalog query succeeded.
Rows: [Row(current_catalog='workspace')]
```

### 3.7 最小 CTAS 確認

```bash
doppler run -- make sql-ctas
```

このコマンドは次を順に流す。

- `CREATE SCHEMA IF NOT EXISTS workspace.default`
- `CREATE OR REPLACE TABLE workspace.default.free_edition_sql_test AS SELECT 1 AS ok`
- `SELECT * FROM workspace.default.free_edition_sql_test`

## 4. 実行コマンド

Make ヘルプ:

```bash
make help
```

Doppler 前提の主導線:

```bash
doppler run -- make sql-test
doppler run -- make sql-catalog
doppler run -- make sql-ctas
doppler run -- make sql-query QUERY="SELECT current_catalog()"
```

ローカル shell に secret が注入済みなら:

```bash
make sql-test
make sql-catalog
make sql-ctas
make sql-query QUERY="SELECT current_catalog()"
```

直接スクリプト実行:

```bash
./scripts/databricks_sql_test.sh
```

任意クエリ:

```bash
./scripts/databricks_sql_test.sh --query "SELECT current_catalog()"
```

catalog 確認:

```bash
./scripts/databricks_sql_test.sh --mode catalog
```

CTAS 確認:

```bash
./scripts/databricks_sql_test.sh --mode ctas
```

## 5. いま扱わないこと

- Databricks Connect を主導線にすること
- notebook 中心の学習
- GCS / volume / external location の設定
- ローカル CSV を直接 Databricks 側から読むこと

これらは Free Edition では前提が不安定なので、このリポジトリの主導線にしない。
