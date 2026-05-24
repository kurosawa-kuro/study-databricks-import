# Managed Volume 検証メモ

## 位置づけ

この検証は、Databricks Free Edition における **次段階の採用候補** である。

現時点で確認済みなのは以下。

- SQL Warehouse へのローカル疎通
- `current_catalog()`
- CTAS
- `customers` / `orders` の `VALUES` 再現

一方で、以下は **未検証**。

- Files API で `/Volumes/...` へアップロード
- notebook / serverless compute から volume 上のファイルを読む
- Delta Table 化

## 検証したいフロー

```text
local / Cloud Run Job / cron
  ↓
GCS からログ取得
  ↓
Databricks Files API or CLI
  ↓
Managed Volume
  ↓
notebook / serverless compute
  ↓
Spark DataFrame
  ↓
Delta Table
  ↓
SQL
```

## 検証順

1. `files` scope token で Files API upload が通るか
2. notebook / serverless compute から `/Volumes/...` を読めるか
3. Delta Table 化できるか

## 必要な追加前提

- `sql` scope token とは別に、`files` scope を持つ token
- もしくは `sql` と `files` の両方を持つ scoped PAT
- Doppler secret `DWH_DATABRICKS_FILES_TOKEN`

## 最小 SQL

- `databricks/sql/05_create_managed_volume.sql`

最小実行コマンド:

```bash
doppler run -- make volume-create
```

## 最小 Files API 例

```bash
doppler run -- make volume-upload \
  LOCAL_FILE=./data/events.json \
  VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json
```

## SQL だけで Delta Table 化する最小例

```bash
doppler run -- make volume-load
```

## notebook / serverless compute での最小読込例

```python
df = (
    spark.read.format("json")
    .option("multiLine", True)
    .load("/Volumes/workspace/default/raw_logs/sample.json")
)

display(df)
```

補助 notebook:

- `databricks/notebooks/01_volume_json_to_delta.py`

## Delta Table 化の最小例

```python
df.write.mode("overwrite").saveAsTable("workspace.default.events_from_volume")
display(spark.sql("SELECT * FROM workspace.default.events_from_volume"))
```

確認用 SQL:

- `databricks/sql/06_load_events_from_volume.sql`
- `databricks/sql/07_verify_events_from_volume.sql`
- `databricks/sql/08_drop_volume_artifacts.sql`

## 判定基準

- Files API upload が 204 を返す
- notebook / serverless compute で volume 上のファイルを読める
- `events_from_volume` を Delta Table として保存できる

## 今の repo での実行順

1. `doppler run -- make volume-create`
2. `doppler run -- make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json`
3. `doppler run -- make volume-load` で `workspace.default.events_from_volume` を作る
4. `doppler run -- make volume-verify` で `workspace.default.events_from_volume` を確認する
5. SQL だけで不足する場合は `databricks/notebooks/01_volume_json_to_delta.py` を補助的に使う
6. 検証をやり直すときは `doppler run -- make volume-clean` で後片付けする
