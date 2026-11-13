
    

    create  table
      "sales_finance"."analytics_marts"."dim_service__dbt_tmp"
  
    
    as (
      select distinct
    service_code,
    case service_code
        when 'BUSINESS'    then 'Business Parcel'
        when 'EXPRESS'     then 'Express Parcel'
        when 'EURO'        then 'Euro Business Parcel'
        when 'SHOP_RETURN' then 'Shop Return'
    end as service_name
from "sales_finance"."analytics_staging"."stg_contracts"
    );
    
  