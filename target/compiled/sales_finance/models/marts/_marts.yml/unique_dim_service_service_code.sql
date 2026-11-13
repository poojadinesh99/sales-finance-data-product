
    
    

select
    service_code as unique_field,
    count(*) as n_records

from "sales_finance"."analytics_marts"."dim_service"
where service_code is not null
group by service_code
having count(*) > 1


