{{ config(materialized='table') }}

with base as (
    select
        transaction_time,
        is_fraud,
        amount
    from {{ ref('stg_transactions') }}
),

agg as (
    select
        toDayOfWeek(transaction_time) as day_of_week,
        toHour(transaction_time) as hour_of_day,
        count() as tx_count,
        sum(is_fraud) as fraud_tx_count,
        (sum(is_fraud) / count()) * 100 as fraud_rate,
        avg(amount) as avg_amount
    from base
    group by day_of_week, hour_of_day
)

select *
from agg
order by fraud_rate desc, fraud_tx_count desc
