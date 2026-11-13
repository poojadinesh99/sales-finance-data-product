select
    contract_id,
    customer_id,
    service_code,
    price_per_parcel,
    currency,
    cast(valid_from as date) as valid_from,
    cast(valid_to as date)   as valid_to
from {{ source('raw', 'contracts') }}