"""Appends the test results of the latest dbt run to a monitoring table (monitoring.dq_results).
Run after `dbt build`:  python monitoring/collect_dq_results.py"""
import json
import re
from pathlib import Path

import duckdb

DB_PATH = "sales_finance.duckdb"
RUN_RESULTS = Path("target/run_results.json")
MANIFEST = Path("target/manifest.json")

results = json.loads(RUN_RESULTS.read_text())
nodes = json.loads(MANIFEST.read_text())["nodes"]
run_id = results["metadata"]["invocation_id"]
run_at = results["metadata"]["generated_at"]

rows = []
for r in results["results"]:
    node = nodes.get(r["unique_id"])
    if not node or node["resource_type"] != "test":
        continue
    meta = node.get("test_metadata")
    if meta:  # generic test: tested object is in the "model" argument
        m = re.search(r"(?:ref|source)\((?:'[^']*',\s*)?'([^']+)'\)", meta["kwargs"].get("model", ""))
        tested = m.group(1) if m else ""
    else:     # singular test: first model it depends on
        tested = (node["depends_on"]["nodes"] or [""])[0].split(".")[-1]
    rows.append((
        run_id, run_at, node["name"],
        meta["name"] if meta else "singular",
        tested, node.get("column_name"),
        r["status"], r.get("failures") or 0,
    ))

con = duckdb.connect(DB_PATH)
con.execute("CREATE SCHEMA IF NOT EXISTS monitoring")
con.execute("""
    CREATE TABLE IF NOT EXISTS monitoring.dq_results (
        run_id VARCHAR, run_at TIMESTAMP, test_name VARCHAR, test_type VARCHAR,
        tested_object VARCHAR, column_name VARCHAR, status VARCHAR, failing_rows INTEGER
    )""")
con.execute("DELETE FROM monitoring.dq_results WHERE run_id = ?", [run_id])
con.executemany("INSERT INTO monitoring.dq_results VALUES (?, ?, ?, ?, ?, ?, ?, ?)", rows)

print(f"Stored {len(rows)} test results for run {run_id[:8]}\n")
print(con.sql("""
    SELECT tested_object, test_type, column_name, status, failing_rows
    FROM monitoring.dq_results
    WHERE run_id = ? AND status <> 'pass'
    ORDER BY failing_rows DESC
""", params=[run_id]))
con.close()
