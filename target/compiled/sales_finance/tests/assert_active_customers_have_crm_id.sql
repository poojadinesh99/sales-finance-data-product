-- Business rule: every active customer must be linked to a CRM record.
select customer_id, customer_name
from "sales_finance"."analytics_marts"."dim_customer"
where is_active and not has_crm_id