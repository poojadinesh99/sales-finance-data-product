
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."relationships_fct_shipments_67e9aaefa7ee1760d71db67cd7f532f1"
    
      
    ) dbt_internal_test