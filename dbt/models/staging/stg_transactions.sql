{{ config(materialized='view') }}

with src as (
    select
        transaction_time,
        merch,
        cat_id,
        amount,
        name_1,
        name_2,
        gender,
        us_state,
        lat,
        lon,
        merchant_lat,
        merchant_lon,
        target
    from {{ source('transactions_db', 'transactions') }}
),

typed as (
    select
        toDateTime(transaction_time) as transaction_time,
        toDate(transaction_time) as transaction_date,
        toUInt8(target) as is_fraud,

        nullIf(trim(merch), '') as merch,
        nullIf(trim(cat_id), '') as cat_id,
        toFloat64(amount) as amount,

        nullIf(trim(name_1), '') as name_1,
        nullIf(trim(name_2), '') as name_2,
        nullIf(trim(gender), '') as gender,

        upper(nullIf(trim(us_state), '')) as us_state,

        toFloat64(lat) as customer_lat,
        toFloat64(lon) as customer_lon,
        toFloat64(merchant_lat) as merchant_lat,
        toFloat64(merchant_lon) as merchant_lon,

        {{ amount_bucket('toFloat64(amount)') }} as amount_bucket,

        (toFloat64(amount) >= 1000) as is_large_amount
    from src
),

final as (
    select *
    from typed
    where transaction_time is not null
      and us_state is not null
      and cat_id is not null
)

select * from final
