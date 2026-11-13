
  
  create view "sales_finance"."analytics_staging"."stg_shipment_costs__dbt_tmp" as (
    select
    shipment_id,
    cost_eur
from "sales_finance"."raw"."shipment_costs"
  );
