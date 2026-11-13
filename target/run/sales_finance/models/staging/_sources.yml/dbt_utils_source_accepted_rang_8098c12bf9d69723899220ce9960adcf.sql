
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."dbt_utils_source_accepted_rang_8098c12bf9d69723899220ce9960adcf"
    
      
    ) dbt_internal_test