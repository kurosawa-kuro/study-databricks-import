.PHONY: help venv install sql-test sql-catalog sql-values volume-create volume-upload volume-clean pipeline-create pipeline-verify sql-query

VENV_DIR := .venv
PYTHON := python3
VENV_PYTHON := $(VENV_DIR)/bin/python
PIP := $(VENV_DIR)/bin/pip

DATABRICKS_SERVER_HOSTNAME ?= dbc-8d3d115b-6eef.cloud.databricks.com
DATABRICKS_HTTP_PATH ?= /sql/1.0/warehouses/37b50097cbed6e52
DATABRICKS_TOKEN ?= $(DWH_DATABRICKS_TOKEN)
DATABRICKS_FILES_TOKEN ?= $(or $(DWH_DATABRICKS_FILES_TOKEN),$(DWH_DATABRICKS_TOKEN))

help:
	@echo "Available targets:"
	@echo "  make venv         - create virtual environment"
	@echo "  make install      - install project dependencies"
	@echo "  make sql-test     - run SELECT 1 against Databricks SQL Warehouse"
	@echo "  make sql-catalog  - run current_catalog()"
	@echo "  make sql-values   - create customers/orders from SQL VALUES"
	@echo "  make volume-create - create managed volume for pipeline input"
	@echo "  make volume-clean  - drop standalone pipeline and managed volume artifacts"
	@echo "  make pipeline-create - create standalone pipeline materialized view from volume"
	@echo "  make pipeline-verify - verify standalone pipeline materialized view"
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
	./scripts/databricks_sql_test.sh --sql-file ./databricks/sql/volume/01_create_managed_volume.sql

volume-upload:
	@test -n "$(LOCAL_FILE)" || (echo 'Usage: make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json' && exit 2)
	@test -n "$(VOLUME_PATH)" || (echo 'Usage: make volume-upload LOCAL_FILE=./data/events.json VOLUME_PATH=/Volumes/workspace/default/raw_logs/sample.json' && exit 2)
	@test -n "$(DATABRICKS_FILES_TOKEN)" || (echo 'Missing DWH_DATABRICKS_TOKEN, DWH_DATABRICKS_FILES_TOKEN, DATABRICKS_TOKEN, or DATABRICKS_FILES_TOKEN' && echo 'Next: doppler secrets set DWH_DATABRICKS_TOKEN=\"<sql-files-scope-pat>\"' && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_FILES_TOKEN="$(DATABRICKS_FILES_TOKEN)" \
	./scripts/databricks_volume_upload.sh "$(LOCAL_FILE)" "$(VOLUME_PATH)"

volume-clean:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --sql-file ./databricks/sql/volume/02_drop_volume_artifacts.sql

pipeline-create:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --sql-file ./databricks/sql/pipeline/01_create_events_pipeline_mv.sql

pipeline-verify:
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --sql-file ./databricks/sql/pipeline/02_verify_events_pipeline_mv.sql

sql-query:
	@test -n "$(QUERY)" || (echo 'Usage: make sql-query QUERY="SELECT 42 AS answer"' && exit 2)
	@test -x "$(VENV_PYTHON)" || (echo "Missing $(VENV_PYTHON). Run 'make install' first." && exit 2)
	@test -n "$(DATABRICKS_TOKEN)" || (echo "Missing DWH_DATABRICKS_TOKEN or DATABRICKS_TOKEN" && exit 2)
	DATABRICKS_SERVER_HOSTNAME="$(DATABRICKS_SERVER_HOSTNAME)" \
	DATABRICKS_HTTP_PATH="$(DATABRICKS_HTTP_PATH)" \
	DATABRICKS_TOKEN="$(DATABRICKS_TOKEN)" \
	./scripts/databricks_sql_test.sh --query "$(QUERY)"
