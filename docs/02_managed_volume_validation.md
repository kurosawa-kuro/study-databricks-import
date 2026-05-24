# Managed Volume 検証メモ

## 位置づけ

この検証は、Databricks Free Edition における **次段階の採用候補** である。

現時点で確認済みなのは以下。

- SQL Warehouse へのローカル疎通
- `current_catalog()`
- CTAS
- `customers` / `orders` の `VALUES` 再現

一方で、以下は **未検証**。

- Managed Volume 作成
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

1. Managed Volume を作れるか
2. `files` scope token で Files API upload が通るか
3. notebook / serverless compute から `/Volumes/...` を読めるか
4. Delta Table 化できるか

## 必要な追加前提

- `sql` scope token とは別に、`files` scope を持つ token
- もしくは `sql` と `files` の両方を持つ scoped PAT

## 最小 SQL

- `databricks/sql/05_create_managed_volume.sql`

## 最小 Files API 例

```bash
curl --request PUT \
  "https://${DATABRICKS_SERVER_HOSTNAME}/api/2.0/fs/files/Volumes/workspace/default/raw_logs/sample.json?overwrite=true" \
  --header "Authorization: Bearer ${DATABRICKS_FILES_TOKEN}" \
  --header "Content-Type: application/octet-stream" \
  --data-binary @./data/events.json
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

## Delta Table 化の最小例

```python
df.write.mode("overwrite").saveAsTable("workspace.default.events_from_volume")
display(spark.sql("SELECT * FROM workspace.default.events_from_volume"))
```

## 判定基準

- `CREATE VOLUME workspace.default.raw_logs` が通る
- Files API upload が 204 を返す
- notebook / serverless compute で volume 上のファイルを読める
- `events_from_volume` を Delta Table として保存できる
