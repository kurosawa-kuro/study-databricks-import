.PHONY: help venv install sql-test sql-catalog sql-ctas sql-values volume-create volume-upload sql-query

VENV_DIR := .venv
PYTHON := python3
VENV_PYTHON := $(VENV_DIR)/bin/python
PIP := $(VENV_DIR)/bin/pip

DATABRICKS_SERVER_HOSTNAME ?= dbc-8d3d115b-6eef.cloud.databricks.com
DATABRICKS_HTTP_PATH ?= /sql/1.0/warehouses/37b50097cbed6e52
DATABRICKS_TOKEN ?= $(DWH_DATABRICKS_TOKEN)
DATABRICKS_FILES_TOKEN ?= $(DWH_DATABRICKS_FILES_TOKEN)

help:
	@echo "Available targets:"
	@echo "  make venv         - create virtual environment"
	@echo "  make install      - install project dependencies"
	@echo "  make sql-test     - run SELECT 1 against Databricks SQL Warehouse"
	@echo "  make sql-catalog  - run current_catalog()"
	@echo "  make sql-ctas     - run minimal CTAS test"
	@echo "  make sql-values   - create customers/orders from SQL VALUES"
	@echo "  make volume-create - create managed volume candidate for Free Edition validation"
	@echo '  make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json'
	@echo '  make sql-query QUERY="SELECT 42 AS answer" - run arbitrary SQL'

venv:
	$(PYTHON) -m venv $(VENV_DIR)

install: venv
	$(PIP) install -e .

sql-test:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh

sql-catalog:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --mode catalog

sql-ctas:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --mode ctas

sql-values:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --mode values

volume-create:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --sql-file ./databricks/sql/05_create_managed_volume.sql

volume-upload:
	@test -n "$(LOCAL_FILE)" || (echo 'Usage: make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json' && exit 2)
	@test -n "$(VOLUME_PATH)" || (echo 'Usage: make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json' && exit 2)
	@test -n "$(DATABRICKS_FILES_TOKEN)" || (echo "Missing DWH_DATABRICKS_FILES_TOKEN or DATABRICKS_FILES_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_FILES_TOKEN="$(DATABRICKS_FILES_TOKEN)" \
	./scripts/databricks_volume_upload.sh "$(LOCAL_FILE)" "$(VOLUME_PATH)"

sql-query:
	@test -n "$(QUERY)" || (echo 'Usage: make sql-query QUERY="SELECT 42 AS answer"' && exit 2)
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --query "$(QUERY)"
