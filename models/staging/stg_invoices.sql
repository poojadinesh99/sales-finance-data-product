select
    invoice_id,
    customer_id,
    service_code,
    cast(invoice_month as date) as invoice_month,
    billed_parcels,
    amount,
    currency
from {{ source('raw', 'invoices') }}