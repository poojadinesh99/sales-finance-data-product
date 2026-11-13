
    
    

with all_values as (

    select
        stage as value_field,
        count(*) as n_records

    from "sales_finance"."raw"."crm_opportunities"
    group by stage

)

select *
from all_values
where value_field not in (
    'Lead','Qualified','Proposal','Won','Lost'
)


