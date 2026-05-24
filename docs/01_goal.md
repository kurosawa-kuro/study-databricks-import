# ゴール

Databricks Free Edition だけを使い、ローカルから SQL Warehouse へ接続して最小 SQL を通す。

## 最低完了ライン

- `SELECT 1` が返る
- `current_catalog()` が返る
- `workspace.default.free_edition_sql_test` を CTAS で作れる
- 作成したテーブルに `SELECT` できる
- `customers` / `orders` を SQL の `VALUES` で再現できる

## 確認済み

以下は実行済み。

- `doppler run -- make sql-test`
- `doppler run -- make sql-catalog`
- `doppler run -- make sql-ctas`
- `doppler run -- make sql-values`
