
    
    

with child as (
    select shipment_id as from_field
    from "sales_finance"."analytics_staging"."stg_shipment_costs"
    where shipment_id is not null
),

parent as (
    select shipment_id as to_field
    from "sales_finance"."analytics_staging"."stg_shipments"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


