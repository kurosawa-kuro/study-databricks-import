CREATE SCHEMA IF NOT EXISTS workspace.default;

CREATE OR REPLACE TABLE workspace.default.free_edition_sql_test AS
SELECT 1 AS ok;

SELECT *
FROM workspace.default.free_edition_sql_test;
