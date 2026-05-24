CREATE OR REPLACE TABLE workspace.default.events_from_volume
AS
SELECT *
FROM read_files(
  '/Volumes/workspace/default/raw_logs/sample.json',
  format => 'json',
  multiLine => true
);

SELECT * FROM workspace.default.events_from_volume;
