#!/usr/bin/env bash
set -euo pipefail

# 1) Wait for ClickHouse
for i in {1..60}; do
  if clickhouse-client --host clickhouse --query "SELECT 1" >/dev/null 2>&1; then
    echo "ClickHouse is up."
    break
  fi
  echo "Waiting for ClickHouse... ($i/60)"
  sleep 1
done

# If still not ready after loop
if ! clickhouse-client --host clickhouse --query "SELECT 1" >/dev/null 2>&1; then
  echo "ERROR: ClickHouse did not become ready in time."
  exit 1
fi

# 2) Run DDL for Kafka/demo pipeline (existing)
if [ -f /sql/01_ddl.sql ]; then
  echo "Running /sql/01_ddl.sql ..."
  clickhouse-client --host clickhouse --multiquery < /sql/01_ddl.sql
else
  echo "ERROR: /sql/01_ddl.sql not found inside container."
  echo "Check docker-compose volumes: ./sql:/sql"
  exit 1
fi

# 3) Run DDL for dbt source table (transactions_db.transactions)
# Create this file locally as: sql/03_transactions_source.sql
if [ -f /sql/03_transactions_source.sql ]; then
  echo "Running /sql/03_transactions_source.sql ..."
  clickhouse-client --host clickhouse --multiquery < /sql/03_transactions_source.sql
else
  echo "ERROR: /sql/03_transactions_source.sql not found inside container."
  echo "Create it in repo: sql/03_transactions_source.sql and mount ./sql:/sql"
  exit 1
fi

# 4) Ensure CSV exists
if [ ! -f /data/train.csv ]; then
  echo "ERROR: /data/train.csv not found inside container."
  echo "Check docker-compose volumes: ./data:/data"
  exit 1
fi

# 5) Make init idempotent (safe re-run)
echo "Truncating transactions_db.transactions ..."
clickhouse-client --host clickhouse --query "TRUNCATE TABLE transactions_db.transactions"

# 6) Load CSV into transactions_db.transactions (minimal approach)
echo "Loading /data/train.csv into transactions_db.transactions ..."
clickhouse-client --host clickhouse \
  --date_time_input_format=best_effort \
  --query="INSERT INTO transactions_db.transactions FORMAT CSVWithNames" \
  < /data/train.csv

# 7) Quick checks
echo "Row count:"
clickhouse-client --host clickhouse --query "SELECT count() FROM transactions_db.transactions"

echo "Sample rows:"
clickhouse-client --host clickhouse --query "SELECT transaction_time, us_state, cat_id, amount, target FROM transactions_db.transactions LIMIT 3"
