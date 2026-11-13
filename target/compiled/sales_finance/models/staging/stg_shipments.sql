select
    shipment_id,
    customer_id,
    service_code,
    cast(pickup_date as date) as pickup_date,
    parcels,
    weight_kg
from "sales_finance"."raw"."shipments"