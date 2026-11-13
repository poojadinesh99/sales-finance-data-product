
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."unique_stg_customers_customer_id"
    
      
    ) dbt_internal_test