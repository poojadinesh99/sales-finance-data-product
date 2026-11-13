
    
    

with all_values as (

    select
        currency as value_field,
        count(*) as n_records

    from "sales_finance"."raw"."invoices"
    group by currency

)

select *
from all_values
where value_field not in (
    'EUR'
)


