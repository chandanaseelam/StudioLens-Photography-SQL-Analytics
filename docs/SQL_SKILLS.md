# SQL skills used in StudioLens

I organized my SQL work from simple exploration to more detailed business queries.

| Skill | Where to find it | What it does |
|---|---|---|
| CREATE TABLE, PK, FK | `database/01_create_tables.sql` | Shows the original 12-table relational design |
| INSERT / SELECT / UPDATE / DELETE | `database/02_crud_practice.sql` | CRUD practice on a temporary table |
| Runnable JOIN and window examples | `database/03_standalone_sql_demo.sql` | Small reproducible demo without the private database |
| COUNT, GROUP BY, WHERE | `sql/02_data_exploration.sql` | Summarizes bookings, cities and customers |
| INNER JOIN / LEFT JOIN | `sql/03_booking_analysis.sql` | Connects bookings with customers and packages |
| SUM, ROUND | `sql/04_revenue_analysis.sql` | Revenue by category and month |
| HAVING and CTEs | `sql/05_customer_analysis.sql` | Identifies customers with repeat completed bookings |
| RANK and LAG | `sql/06_window_functions.sql` | Revenue ranking and previous-month comparison |
| COALESCE, TRIM, LOWER, CASE | `sql/01_data_quality.sql` | Checks and standardizes values for reporting |
| KPIs | `sql/07_selected_kpis.sql` | Headline metrics and reporting |

The full modeled results were produced with a larger private PostgreSQL dataset. The standalone demo uses only 10 fictional bookings; its totals are deliberately different.
