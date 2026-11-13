
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."dbt_utils_source_accepted_range_raw_shipment_costs_cost_eur__0"
    
      
    ) dbt_internal_test