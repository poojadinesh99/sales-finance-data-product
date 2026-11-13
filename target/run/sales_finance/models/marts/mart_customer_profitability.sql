
    

    create  table
      "sales_finance"."analytics_marts"."mart_customer_profitability__dbt_tmp"
  
    
    as (
      -- revenue, cost and contribution margin per customer and month (clean records only)
with revenue as (
    select customer_id, invoice_month as month_start, sum(amount) as revenue_eur
    from "sales_finance"."analytics_marts"."fct_invoices"
    where not is_wrong_currency and not is_amount_mismatch and not is_invalid_contract_price
    group by 1, 2
),

costs as (
    select
        customer_id,
        cast(date_trunc('month', pickup_date) as date) as month_start,
        sum(parcels)  as parcels,
        sum(cost_eur) as cost_eur
    from "sales_finance"."analytics_marts"."fct_shipments"
    where is_known_customer and not is_negative_cost
    group by 1, 2
)

select
    c.customer_id,
    d.customer_name,
    d.segment,
    d.country_code,
    c.month_start,
    c.parcels,
    r.revenue_eur,
    c.cost_eur,
    r.revenue_eur - c.cost_eur                                  as contribution_margin_eur,
    round((r.revenue_eur - c.cost_eur) / nullif(r.revenue_eur, 0), 3) as contribution_margin_pct
from costs c
join "sales_finance"."analytics_marts"."dim_customer" d on c.customer_id = d.customer_id
left join revenue r on c.customer_id = r.customer_id and c.month_start = r.month_start
    );
    
  