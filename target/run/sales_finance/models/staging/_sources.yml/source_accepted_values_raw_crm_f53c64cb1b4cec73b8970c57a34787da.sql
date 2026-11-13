
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "sales_finance"."analytics_dbt_test__audit"."source_accepted_values_raw_crm_f53c64cb1b4cec73b8970c57a34787da"
    
      
    ) dbt_internal_test