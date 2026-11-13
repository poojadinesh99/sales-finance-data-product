
    

    create  table
      "sales_finance"."analytics_marts"."fct_invoices__dbt_tmp"
  
    
    as (
      select * from "sales_finance"."analytics_intermediate"."int_invoices_checked"
    );
    
  