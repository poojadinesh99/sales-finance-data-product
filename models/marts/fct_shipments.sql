select
    s.shipment_id,
    s.customer_id,
    s.service_code,
    s.pickup_date,
    s.parcels,
    s.weight_kg,
    c.cost_eur,
    c.cost_eur < 0           as is_negative_cost,
    d.customer_id is not null as is_known_customer
from {{ ref('stg_shipments') }} s
left join {{ ref('stg_shipment_costs') }} c on s.shipment_id = c.shipment_id
left join {{ ref('dim_customer') }} d       on s.customer_id = d.customer_id