{{ config(materialized='table') }}

with base as (
    select
        merch,
        amount,
        is_fraud
    from {{ ref('stg_transactions') }}
),

agg as (
    select
        merch,
        count() as tx_count,
        sum(amount) as total_amount,
        sum(is_fraud) as fraud_tx_count,
        (sum(is_fraud) / count()) * 100 as fraud_rate,
        avg(amount) as avg_amount
    from base
    group by merch
),

final as (
    select
        *,
        (fraud_rate >= 5 and fraud_tx_count >= 10) as is_suspicious
    from agg
)

select *
from final
order by is_suspicious desc, fraud_rate desc, fraud_tx_count desc
