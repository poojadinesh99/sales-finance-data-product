





with validation_errors as (

    select
        customer_id, month_start
    from "sales_finance"."analytics_marts"."mart_customer_profitability"
    group by customer_id, month_start
    having count(*) > 1

)

select *
from validation_errors


