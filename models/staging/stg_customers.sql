-- one row per customer: removes exact duplicates from the CRM export
with source as (
    select * from {{ source('raw', 'customers') }}
)

select
    customer_id,
    crm_id,
    customer_name,
    country       as country_code,
    segment,
    cast(created_at as date) as customer_since,
    is_active
from source
qualify row_number() over (partition by customer_id order by created_at) = 1