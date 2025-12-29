{{ config(materialized='table') }}

with base as (
    select
        us_state,
        amount,
        is_fraud,
        concat(name_1, ' ', name_2) as customer_name,
        merch
    from {{ ref('stg_transactions') }}
),

agg as (
    select
        us_state,
        count() as tx_count,
        sum(amount) as total_amount,
        sumIf(amount, is_fraud = 1) as fraud_amount,
        sum(is_fraud) as fraud_tx_count,
        (sum(is_fraud) / count()) * 100 as fraud_rate,
        uniqExact(customer_name) as uniq_customers,
        uniqExact(merch) as uniq_merchants
    from base
    group by us_state
)

select *
from agg
order by fraud_rate desc, fraud_tx_count desc
