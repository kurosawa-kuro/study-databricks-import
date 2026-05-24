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
DEFAULT_VALUES_STATEMENTS = [
    "CREATE SCHEMA IF NOT EXISTS workspace.default",
    """
    CREATE OR REPLACE TABLE workspace.default.customers (
      customer_id INT,
      name STRING,
      age INT,
      prefecture STRING,
      signup_date DATE
    )
    """,
    """
    INSERT OVERWRITE workspace.default.customers
    VALUES
      (1, 'Taro Yamada', 34, 'Tokyo', DATE '2024-01-10'),
      (2, 'Hanako Sato', 28, 'Osaka', DATE '2024-02-15'),
      (3, 'Ken Suzuki', 41, 'Hokkaido', DATE '2024-03-20')
    """,
    """
    CREATE OR REPLACE TABLE workspace.default.orders (
      order_id INT,
      customer_id INT,
      amount INT,
      ordered_at TIMESTAMP
    )
    """,
    """
    INSERT OVERWRITE workspace.default.orders
    VALUES
      (101, 1, 12000, TIMESTAMP '2024-04-01 10:30:00'),
      (102, 1, 8000, TIMESTAMP '2024-04-03 14:20:00'),
      (103, 2, 15000, TIMESTAMP '2024-04-05 09:10:00'),
      (104, 3, 6000, TIMESTAMP '2024-04-07 18:45:00')
    """,
    """
    SELECT
      c.customer_id,
      c.name,
      c.prefecture,
      COUNT(o.order_id) AS order_count,
      COALESCE(SUM(o.amount), 0) AS total_amount
    FROM workspace.default.customers c
    LEFT JOIN workspace.default.orders o
      ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.name, c.prefecture
    ORDER BY total_amount DESC
    """,
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
        choices=["query", "catalog", "ctas", "values"],
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

            if args.mode == "values":
                last_rows = None
                for statement in DEFAULT_VALUES_STATEMENTS:
                    cursor.execute(statement)
                    try:
                        last_rows = cursor.fetchall()
                    except Exception:
                        last_rows = None

                print("Databricks SQL VALUES test succeeded.")
                print("Statements:")
                for statement in DEFAULT_VALUES_STATEMENTS:
                    one_line = " ".join(statement.split())
                    print(f"- {one_line}")
                print(f"Rows: {last_rows}")
                return


if __name__ == "__main__":
    main()
