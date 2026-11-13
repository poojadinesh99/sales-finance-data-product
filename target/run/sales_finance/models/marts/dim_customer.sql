
    

    create  table
      "sales_finance"."analytics_marts"."dim_customer__dbt_tmp"
  
    
    as (
      select
    customer_id,
    crm_id,
    customer_name,
    country_code,
    segment,
    customer_since,
    is_active,
    crm_id is not null as has_crm_id
from "sales_finance"."analytics_staging"."stg_customers"
    );
    
  