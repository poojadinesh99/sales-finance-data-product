-- business rule: invoiced amount = billed parcels x contract price valid in the invoice month
with invoices as (
    select * from {{ ref('stg_invoices') }}
),

prices as (
    select * from {{ ref('int_contract_prices') }}
)

select
    i.invoice_id,
    i.customer_id,
    i.service_code,
    i.invoice_month,
    i.billed_parcels,
    i.amount,
    i.currency,
    p.price_per_parcel                                   as contract_price,
    round(i.billed_parcels * p.price_per_parcel, 2)      as expected_amount,
    round(i.amount - i.billed_parcels * p.price_per_parcel, 2) as amount_difference,
    abs(i.amount - i.billed_parcels * p.price_per_parcel) > 0.01 as is_amount_mismatch,
    i.currency <> 'EUR'                                  as is_wrong_currency,
    coalesce(p.is_invalid_price, true)                   as is_invalid_contract_price
from invoices i
left join prices p
    on  i.customer_id  = p.customer_id
    and i.service_code = p.service_code
    and i.invoice_month between p.valid_from and p.valid_to
