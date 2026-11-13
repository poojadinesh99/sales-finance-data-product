
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."dbt_utils_unique_combination_o_fe6ab81ef72efb3bd0fc828f22bebd42"
    
      
    ) dbt_internal_test