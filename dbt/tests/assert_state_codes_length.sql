select *
from {{ ref('stg_transactions') }}
where length(us_state) != 2
