select
    shipment_id,
    cost_eur
from {{ source('raw', 'shipment_costs') }}