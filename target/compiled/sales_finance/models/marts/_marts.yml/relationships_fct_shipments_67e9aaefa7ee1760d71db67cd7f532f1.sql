
    
    

with child as (
    select service_code as from_field
    from "sales_finance"."analytics_marts"."fct_shipments"
    where service_code is not null
),

parent as (
    select service_code as to_field
    from "sales_finance"."analytics_marts"."dim_service"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


