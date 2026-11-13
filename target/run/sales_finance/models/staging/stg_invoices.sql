
  
  create view "sales_finance"."analytics_staging"."stg_invoices__dbt_tmp" as (
    select
    invoice_id,
    customer_id,
    service_code,
    cast(invoice_month as date) as invoice_month,
    billed_parcels,
    amount,
    currency
from "sales_finance"."raw"."invoices"
  );
