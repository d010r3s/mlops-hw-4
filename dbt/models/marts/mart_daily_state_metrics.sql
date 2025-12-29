{{ config(materialized='table') }}

with base as (
    select
        transaction_date,
        us_state,
        amount,
        is_large_amount
    from {{ ref('stg_transactions') }}
),

agg as (
    select
        transaction_date,
        us_state,
        count() as tx_count,
        sum(amount) as total_amount,
        avg(amount) as avg_amount,
        quantileExact(0.95)(amount) as p95_amount,
        avg(toUInt8(is_large_amount)) * 100 as pct_large_tx
    from base
    group by transaction_date, us_state
)

select * from agg
