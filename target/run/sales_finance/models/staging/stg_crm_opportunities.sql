
  
  create view "sales_finance"."analytics_staging"."stg_crm_opportunities__dbt_tmp" as (
    select
    opportunity_id,
    crm_id,
    stage,
    expected_parcels_per_month,
    cast(created_at as date) as created_date
from "sales_finance"."raw"."crm_opportunities"
  );
