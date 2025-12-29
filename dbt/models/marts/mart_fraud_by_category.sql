{{ config(materialized='table') }}

with base as (
    select
        cat_id,
        amount,
        is_fraud
    from {{ ref('stg_transactions') }}
),

agg as (
    select
        cat_id,
        count() as tx_count,
        sum(amount) as total_amount,
        sumIf(amount, is_fraud = 1) as fraud_amount,
        sum(is_fraud) as fraud_tx_count,
        (sum(is_fraud) / count()) * 100 as fraud_rate
    from base
    group by cat_id
)

select *
from agg
order by fraud_rate desc, fraud_tx_count desc
