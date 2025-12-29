select *
from {{ ref('stg_transactions') }}
where is_fraud not in (0, 1)
