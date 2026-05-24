# Databricks notebook source
# Free Edition の Managed Volume 検証用。
# /Volumes/... にアップロードした JSON を読み、Delta Table に保存する。

volume_path = "/Volumes/workspace/default/raw_logs/sample.json"
target_table = "workspace.default.events_from_volume"

# COMMAND ----------

df = (
    spark.read.format("json")
    .option("multiLine", True)
    .load(volume_path)
)

display(df)

# COMMAND ----------

df.write.mode("overwrite").saveAsTable(target_table)

# COMMAND ----------

display(spark.sql(f"SELECT * FROM {target_table}"))

# COMMAND ----------

display(
    spark.sql(
        f"""
        SELECT
          COUNT(*) AS row_count
        FROM {target_table}
        """
    )
)
