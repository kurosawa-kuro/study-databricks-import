from __future__ import annotations

import argparse
import os
import sys

from databricks import sql


DEFAULT_TEST_QUERY = "SELECT 1 AS ok"
DEFAULT_CATALOG_QUERY = "SELECT current_catalog() AS current_catalog"
DEFAULT_CTAS_STATEMENTS = [
    "CREATE SCHEMA IF NOT EXISTS workspace.default",
    "CREATE OR REPLACE TABLE workspace.default.free_edition_sql_test AS SELECT 1 AS ok",
    "SELECT * FROM workspace.default.free_edition_sql_test",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Test Databricks Free Edition SQL Warehouse connectivity."
    )
    parser.add_argument(
        "--query",
        default=DEFAULT_TEST_QUERY,
        help="SQL query to run after connecting.",
    )
    parser.add_argument(
        "--mode",
        choices=["query", "catalog", "ctas"],
        default="query",
        help="Predefined SQL flow to run.",
    )
    return parser.parse_args()


def require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        print(f"Missing required environment variable: {name}", file=sys.stderr)
        raise SystemExit(2)
    return value


def main() -> None:
    args = parse_args()

    server_hostname = require_env("DATABRICKS_SERVER_HOSTNAME")
    http_path = require_env("DATABRICKS_HTTP_PATH")
    access_token = require_env("DATABRICKS_TOKEN")

    with sql.connect(
        server_hostname=server_hostname,
        http_path=http_path,
        access_token=access_token,
    ) as connection:
        with connection.cursor() as cursor:
            if args.mode == "query":
                cursor.execute(args.query)
                rows = cursor.fetchall()
                print("Databricks SQL connectivity succeeded.")
                print(f"Query: {args.query}")
                print(f"Rows: {rows}")
                return

            if args.mode == "catalog":
                cursor.execute(DEFAULT_CATALOG_QUERY)
                rows = cursor.fetchall()
                print("Databricks SQL catalog query succeeded.")
                print(f"Query: {DEFAULT_CATALOG_QUERY}")
                print(f"Rows: {rows}")
                return

            if args.mode == "ctas":
                last_rows = None
                for statement in DEFAULT_CTAS_STATEMENTS:
                    cursor.execute(statement)
                    try:
                        last_rows = cursor.fetchall()
                    except Exception:
                        last_rows = None

                print("Databricks SQL CTAS test succeeded.")
                print("Statements:")
                for statement in DEFAULT_CTAS_STATEMENTS:
                    print(f"- {statement}")
                print(f"Rows: {last_rows}")
                return


if __name__ == "__main__":
    main()
