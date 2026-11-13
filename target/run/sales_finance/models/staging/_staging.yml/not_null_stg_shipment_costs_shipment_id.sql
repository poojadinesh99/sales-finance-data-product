
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."not_null_stg_shipment_costs_shipment_id"
    
      
    ) dbt_internal_test