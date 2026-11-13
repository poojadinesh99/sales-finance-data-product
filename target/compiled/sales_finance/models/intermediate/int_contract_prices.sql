-- contract price history with an open-ended validity for the current price
select
    contract_id,
    customer_id,
    service_code,
    price_per_parcel,
    valid_from,
    coalesce(valid_to, date '9999-12-31') as valid_to,
    price_per_parcel <= 0                 as is_invalid_price
from "sales_finance"."analytics_staging"."stg_contracts"