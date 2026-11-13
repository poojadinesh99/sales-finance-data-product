# Sales Finance Data Product — dbt + DuckDB (Snowflake-ready)

![dbt CI](https://github.com/poojadinesh99/sales-finance-data-product/actions/workflows/dbt_ci.yml/badge.svg)

Customer-level sales and finance view for a fictional parcel logistics company:
CRM leads and opportunities → parcel volumes and contract prices → revenue, costs and
contribution margin per customer and month, with automated data quality checks in every layer.

All data is **synthetic** (Python, Faker). Data quality issues are injected on purpose
so the tests catch realistic problems.

## Architecture

Python generator → DuckDB raw → dbt staging → intermediate → marts (star schema)
│ │
source tests business-rule tests
└──────→ monitoring.dq_results ←┘


## Data model

| Layer | Models |
|---|---|
| Staging | `stg_customers` (deduplicated), `stg_crm_opportunities`, `stg_contracts`, `stg_shipments`, `stg_shipment_costs`, `stg_invoices` |
| Intermediate | `int_contract_prices` (price validity periods), `int_invoices_checked` (invoice vs. contract price) |
| Marts | `fct_shipments`, `fct_invoices`, `dim_customer`, `dim_service`, `dim_date`, `mart_customer_profitability` |

`mart_customer_profitability`: parcels, revenue, cost, contribution margin (EUR and %) per customer and month, based on validated records only.

## Data quality concept

- **44 automated dbt tests** on source, staging and mart level (`unique`, `not_null`, `relationships`, `accepted_values`, `dbt_utils.accepted_range`)
- **Business-rule tests:**
  - invoiced amount = billed parcels × contract price valid in the invoice month (tolerance 1 cent)
  - every active customer has a CRM ID
- **Fail-soft:** tests run with severity `warn` and `store_failures`, so the pipeline continues and failing rows are stored for analysis
- **Monitoring:** `monitoring/collect_dq_results.py` appends the results of every run to `monitoring.dq_results` (test, tested object, status, failing rows)
- **CI/CD:** GitHub Actions generates the data and runs `dbt build` on every push and pull request

### Detected issues (current run)

| Check | Failing rows | Cause |
|---|---|---|
| Invoice amount ≠ parcels × contract price | 84 | 40 manipulated amounts + 44 follow-on errors from 3 contracts with negative prices |
| Shipments without known customer | 20 | orphaned customer IDs |
| Negative shipment costs | 10 | invalid cost records |
| Customers without CRM ID | 6 (4 active) | missing CRM link |
| Duplicate customers in raw data | 5 | duplicate CRM export rows, removed in staging |
| Negative contract prices | 3 | invalid price records |
| Invoices not in EUR | 1 value (15 rows) | currency mix-up |

## Tech stack

dbt Core · dbt_utils · DuckDB · Python (pandas, Faker) · Git · GitHub Actions

## How to run

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python data_generator/generate_data.py
dbt deps
dbt build
python monitoring/collect_dq_results.py
```

Requires a `sales_finance` profile in `~/.dbt/profiles.yml` (type `duckdb`, path `sales_finance.duckdb`).

## Status

- [x] Repository and dbt project structure
- [x] Synthetic data generator with injected DQ issues
- [x] Staging models + source tests
- [x] Star schema marts
- [x] Business-rule tests
- [x] DQ monitoring table
- [x] GitHub Actions CI
- [ ] Data profiling report on raw data
- [ ] SCD2 snapshot of contract prices
- [ ] Snowflake target (in addition to DuckDB)
