# ゴール

Databricks Free Edition だけを使い、ローカルから SQL Warehouse へ接続して最小 SQL を通す。

## 最低完了ライン

- `SELECT 1` が返る
- `current_catalog()` が返る
- `workspace.default.free_edition_sql_test` を CTAS で作れる
- 作成したテーブルに `SELECT` できる
