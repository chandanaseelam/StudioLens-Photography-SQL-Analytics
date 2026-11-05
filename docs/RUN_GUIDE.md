# StudioLens — how to run the public code

## Option 1: Try the self-contained SQL demo

This is the best starting point for someone browsing the GitHub repo.

1. Open PostgreSQL in DBeaver (any database where you have permission to create temporary tables).
2. Open `database/03_standalone_sql_demo.sql`.
3. Run it as a whole SQL script in **one session/connection**, so the temporary tables remain available until `ROLLBACK`.
4. Review the booking status, category revenue, repeat customer, rank, and monthly results.
5. The demo ends with `ROLLBACK`: it leaves your existing database data unchanged.

You can also run `database/02_crud_practice.sql` to practice all four CRUD operations safely.

## Option 2: Review the original analysis

The `sql/` files were written for my full, populated local StudioLens database (`studiolens_db`). They require 12 tables and two historical reporting views, `public.v_studiolens_bookings_asof` and `public.v_studiolens_invoices_asof`. The private migration defines these views and additional data-integrity logic, which are **not included** in this public repository.

`database/01_create_tables.sql` is the **initial schema reference**, intended for a fresh empty PostgreSQL database only. It does not recreate the private data or migration; do not run it against the existing populated database.

## Files in the repository

- `database/`: original schema reference, CRUD practice and a stand-alone demo.
- `sql/`: data checks, exploration, booking and revenue analysis, customer analysis, ranking and selected KPIs.
- `reports/`: CSVs exported or reviewed from synthetic data. Months with no completions are explicitly tagged in the 34-month calendar file.
- `charts/`: charts created from the summary data, not illustrative/AI-generated photography artwork.
- `diagrams/`: diagrams generated from the initial DDL with Graphviz; the `.dot` files are included.
- `screenshots/`: screenshots of my live schema and example query results; these are evidence, not standalone database exports.
- `docs/`: business findings and database design notes.

## Data limitations

The 98,573-record underlying dataset was synthetically generated. Published reports are evidence of analysis outputs, not a real business dataset. A visitor can run the small independent SQL demo, but cannot reproduce the published full-dataset KPIs without the private source data and later views. The simple 12% cancellation share is not the approved 30-day cohort KPI.
