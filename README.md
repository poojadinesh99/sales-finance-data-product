# Sales Finance Data Product — Snowflake + dbt

Customer-level sales and finance view for a fictional parcel logistics company:
CRM leads and opportunities → parcel volumes and prices → revenue, costs and
contribution margin per customer, with data quality checks in every layer.

All data is synthetic (Python, Faker). Data quality issues (duplicates, orphaned keys,
negative prices, missing CRM IDs) are injected on purpose so the tests catch real problems.

## Architecture
Python generator → Snowflake RAW → dbt staging → intermediate → marts (star schema) → dq_results

## Data model (marts)
- fct_shipments: one row per parcel shipment
- fct_invoices: one row per invoice line
- dim_customer, dim_date, dim_service
- snap_customer_prices: SCD2 history of contract prices

## Data quality concept
1. Profiling of raw data (row counts, null rates, distributions, key uniqueness)
2. Generic dbt tests: unique, not_null, relationships, accepted_values
3. Business-rule tests: invoiced amount = billed parcels × contract price; every active customer has a CRM ID; no negative prices or costs
4. Monitoring: results of every run stored in dq_results
5. CI/CD: dbt build on every pull request (GitHub Actions)

## Tech stack
Snowflake · dbt Core · dbt_utils · Python (pandas, Faker) · Git · GitHub Actions

## Status
- [x] Repository and dbt project structure
- [ ] Snowflake setup
- [ ] Synthetic data generator with injected DQ issues
- [ ] Staging models + source tests
- [ ] Star schema marts + SCD2 snapshot
- [ ] Business-rule tests
- [ ] DQ monitoring table
- [ ] GitHub Actions CI