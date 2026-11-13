-- Business rule: invoiced amount must equal billed parcels x contract price (tolerance 1 cent).
-- Returns every invoice that breaks the rule.
select
    invoice_id,
    customer_id,
    service_code,
    invoice_month,
    billed_parcels,
    contract_price,
    amount,
    expected_amount,
    amount_difference
from {{ ref('int_invoices_checked') }}
where is_amount_mismatch