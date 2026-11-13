
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."relationships_fct_shipments_600479468b74d4708adb692a1023378d"
    
      
    ) dbt_internal_test