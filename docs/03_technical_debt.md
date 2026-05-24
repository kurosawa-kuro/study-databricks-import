# 技術的債務

## いま未対応

- GCS からの取得
- Cloud Run Job / cron 連携
- streaming table 化
- 差分取り込みの自動化
- pipeline refresh 戦略の整理
- pipeline 監視とエラー運用

## repo 内の債務

- SQL ファイルが増えてきたので、`foundation / volume / pipeline` などに再編余地がある
- 実行結果サマリを自動保存する仕組みはまだない

## 方針として残すもの

- `data/` は参照用 fixture のまま維持する
- `DWH_DATABRICKS_TOKEN` は `sql, files` の両 scope を前提にする
- GCS は後回しとし、先に Databricks Free Edition 内で閉じるパイプライン学習を優先する
