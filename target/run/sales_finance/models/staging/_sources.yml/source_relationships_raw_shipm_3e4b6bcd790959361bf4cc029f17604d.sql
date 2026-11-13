
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."source_relationships_raw_shipm_3e4b6bcd790959361bf4cc029f17604d"
    
      
    ) dbt_internal_test