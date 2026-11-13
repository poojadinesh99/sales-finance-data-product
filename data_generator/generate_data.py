"""Generates synthetic sales & finance data for a fictional parcel company
and loads it into DuckDB (schema raw). Data quality issues are injected on purpose."""
import random
from datetime import date, timedelta

import duckdb
import pandas as pd
from faker import Faker

SEED = 42
random.seed(SEED)
Faker.seed(SEED)
fake = Faker("de_DE")

DB_PATH = "sales_finance.duckdb"
N_CUSTOMERS = 300
START, END = date(2025, 1, 1), date(2026, 10, 31)
PRICE_CHANGE_DATE = date(2026, 1, 1)
COUNTRIES = ["DE", "AT", "NL", "FR", "ES", "PT"]
SEGMENTS = ["SME", "Key Account", "E-Commerce"]
SERVICES = {"BUSINESS": 4.20, "EXPRESS": 9.80, "EURO": 6.50, "SHOP_RETURN": 3.10}


def rand_date(a, b):
    return a + timedelta(days=random.randint(0, (b - a).days))


# ---------- customers ----------
customers = [
    {
        "customer_id": f"C{i:04d}",
        "crm_id": f"CRM-{100000 + i}",
        "customer_name": fake.company(),
        "country": random.choice(COUNTRIES),
        "segment": random.choices(SEGMENTS, weights=[6, 1, 3])[0],
        "created_at": rand_date(date(2023, 1, 1), START),
        "is_active": random.random() > 0.1,
    }
    for i in range(1, N_CUSTOMERS + 1)
]

# ---------- CRM opportunities (won = customers, rest = open/lost leads) ----------
crm_opportunities = [
    {
        "opportunity_id": f"OPP-{i:05d}",
        "crm_id": f"CRM-{100000 + i}",
        "stage": "Won" if i <= N_CUSTOMERS else random.choice(["Lead", "Qualified", "Proposal", "Lost"]),
        "expected_parcels_per_month": random.choice([50, 100, 250, 500, 1000, 5000]),
        "created_at": rand_date(date(2022, 6, 1), END),
    }
    for i in range(1, 501)
]

# ---------- contracts (price per parcel, some with a price change on 2026-01-01) ----------
contracts = []
for c in customers:
    for svc in random.sample(list(SERVICES), k=random.randint(1, 3)):
        price = SERVICES[svc] * random.uniform(0.8, 1.2) * (0.85 if c["segment"] == "Key Account" else 1)
        changes = random.random() < 0.3
        contracts.append({
            "contract_id": f"K{len(contracts) + 1:05d}", "customer_id": c["customer_id"],
            "service_code": svc, "price_per_parcel": round(price, 2), "currency": "EUR",
            "valid_from": START, "valid_to": PRICE_CHANGE_DATE - timedelta(days=1) if changes else None,
        })
        if changes:
            contracts.append({
                "contract_id": f"K{len(contracts) + 1:05d}", "customer_id": c["customer_id"],
                "service_code": svc, "price_per_parcel": round(price * 1.05, 2), "currency": "EUR",
                "valid_from": PRICE_CHANGE_DATE, "valid_to": None,
            })


def price_on(customer_id, service_code, day):
    for k in contracts:
        if (k["customer_id"] == customer_id and k["service_code"] == service_code
                and k["valid_from"] <= day and (k["valid_to"] is None or day <= k["valid_to"])):
            return k["price_per_parcel"]
    return None


# ---------- shipments (one row per weekly pickup) and costs ----------
shipments, shipment_costs = [], []
for cust_id, svc in {(k["customer_id"], k["service_code"]) for k in contracts}:
    volume = random.choice([5, 20, 60, 200])
    day = START + timedelta(days=random.randint(0, 6))
    while day <= END:
        parcels = max(1, int(random.gauss(volume, volume * 0.3)))
        sid = f"S{len(shipments) + 1:07d}"
        shipments.append({
            "shipment_id": sid, "customer_id": cust_id, "service_code": svc,
            "pickup_date": day, "parcels": parcels,
            "weight_kg": round(parcels * random.uniform(1, 8), 1),
        })
        shipment_costs.append({
            "shipment_id": sid,
            "cost_eur": round(parcels * SERVICES[svc] * random.uniform(0.6, 0.85), 2),
        })
        day += timedelta(days=7)

# ---------- invoices (monthly: billed parcels x contract price) ----------
ship_df = pd.DataFrame(shipments)
ship_df["invoice_month"] = pd.to_datetime(ship_df["pickup_date"]).dt.to_period("M").dt.to_timestamp()
monthly = ship_df.groupby(["customer_id", "service_code", "invoice_month"], as_index=False)["parcels"].sum()
invoices = []
for r in monthly.itertuples():
    price = price_on(r.customer_id, r.service_code, r.invoice_month.date())
    invoices.append({
        "invoice_id": f"INV-{len(invoices) + 1:06d}", "customer_id": r.customer_id,
        "service_code": r.service_code, "invoice_month": r.invoice_month.date(),
        "billed_parcels": r.parcels, "amount": round(r.parcels * price, 2), "currency": "EUR",
    })

# ---------- inject data quality issues ----------
issues = {}
for c in random.sample(customers, 6):                      # missing CRM IDs
    c["crm_id"] = None
issues["customers_missing_crm_id"] = 6
customers += [dict(c) for c in random.sample(customers, 5)]  # duplicate customers
issues["customers_duplicated"] = 5
for k in random.sample(contracts, 3):                      # negative prices
    k["price_per_parcel"] = -k["price_per_parcel"]
issues["contracts_negative_price"] = 3
for s in random.sample(shipments, 20):                     # orphaned shipments
    s["customer_id"] = "C9999"
issues["shipments_unknown_customer"] = 20
for sc in random.sample(shipment_costs, 10):               # negative costs
    sc["cost_eur"] = -sc["cost_eur"]
issues["costs_negative"] = 10
for inv in random.sample(invoices, 40):                    # amount does not match contract price
    inv["amount"] = round(inv["amount"] * random.choice([0.9, 1.15]), 2)
issues["invoices_amount_mismatch"] = 40
for inv in random.sample(invoices, 15):                    # wrong currency
    inv["currency"] = "USD"
issues["invoices_wrong_currency"] = 15

# ---------- load into DuckDB, schema raw ----------
tables = {
    "customers": customers, "crm_opportunities": crm_opportunities, "contracts": contracts,
    "shipments": shipments, "shipment_costs": shipment_costs, "invoices": invoices,
}
con = duckdb.connect(DB_PATH)
con.execute("CREATE SCHEMA IF NOT EXISTS raw")
for name, rows in tables.items():
    df = pd.DataFrame(rows)
    con.register("tmp_df", df)
    con.execute(f"CREATE OR REPLACE TABLE raw.{name} AS SELECT * FROM tmp_df")
    con.unregister("tmp_df")
    print(f"raw.{name:<18} {len(df):>7} rows")
con.close()

print("\nInjected data quality issues:")
for k, v in issues.items():
    print(f"  {k:<28} {v}")