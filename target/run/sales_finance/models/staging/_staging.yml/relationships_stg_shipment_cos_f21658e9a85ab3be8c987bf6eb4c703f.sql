
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."relationships_stg_shipment_cos_f21658e9a85ab3be8c987bf6eb4c703f"
    
      
    ) dbt_internal_test