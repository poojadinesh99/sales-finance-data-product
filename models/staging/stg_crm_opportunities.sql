select
    opportunity_id,
    crm_id,
    stage,
    expected_parcels_per_month,
    cast(created_at as date) as created_date
from {{ source('raw', 'crm_opportunities') }}