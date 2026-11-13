select
    customer_id,
    crm_id,
    customer_name,
    country_code,
    segment,
    customer_since,
    is_active,
    crm_id is not null as has_crm_id
from {{ ref('stg_customers') }}