# dbt project: transactions_dbt (ClickHouse)

Этот каталог содержит dbt-проект поверх таблицы `transactions_db.transactions` в ClickHouse.

## Быстрый запуск

```bash
cd dbt

pip install -r requirements.txt

# dbt будет читать профайл из этого каталога
set DBT_PROFILES_DIR=.

dbt deps
dbt seed
dbt run
dbt test

dbt docs generate
dbt docs serve
```

## Что реализовано

- Слои: **sources → staging → marts**
- Макрос: `amount_bucket` (используется в `stg_transactions`)
- Пакеты: `dbt_utils`, `dbt_date`, `dbt_expectations`
- Витрины (6/6):
  - `mart_daily_state_metrics`
  - `mart_fraud_by_category`
  - `mart_fraud_by_state`
  - `mart_customer_risk_profile`
  - `mart_hourly_fraud_pattern`
  - `mart_merchant_analytics`
- `schema.yml` с описаниями и тестами
- Singular tests в `tests/`
- Unit tests (dbt>=1.8) в `unit_tests/`
- `sqlfluff` + `.pre-commit-config.yaml`
- `Makefile`
