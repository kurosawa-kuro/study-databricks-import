CREATE OR REFRESH MATERIALIZED VIEW workspace.default.events_from_volume_mv
AS
SELECT *
FROM read_files(
  '/Volumes/workspace/default/raw_logs/sample.json',
  format => 'json',
  multiLine => true
);

SELECT * FROM workspace.default.events_from_volume_mv;
