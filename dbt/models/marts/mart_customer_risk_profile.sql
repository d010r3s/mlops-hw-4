{{ config(materialized='table') }}

with base as (
    select
        concat(name_1, ' ', name_2) as customer_name,
        amount,
        is_fraud
    from {{ ref('stg_transactions') }}
),

agg as (
    select
        customer_name,
        count() as tx_count,
        sum(is_fraud) as fraud_tx_count,
        (sum(is_fraud) / count()) * 100 as fraud_rate,
        avg(amount) as avg_amount,
        quantileExact(0.95)(amount) as p95_amount
    from base
    group by customer_name
),

segmented as (
    select
        *,
        case
            when fraud_rate >= 10 then 'HIGH'
            when fraud_rate >= 3 then 'MEDIUM'
            else 'LOW'
        end as risk_segment
    from agg
)

select *
from segmented
