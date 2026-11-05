# What's inside this GitHub project

- `README.md`: short overview, my SQL work and findings from the synthetic dataset.
- `database/`: initial 12-table PostgreSQL schema, safe CRUD exercise, and a standalone mini-demo.
- `sql/`: data checks, exploration, bookings, revenue, customer queries, window functions and selected KPIs.
- `diagrams/`: schema diagrams generated programmatically from the original SQL definitions (`.dot`, `.png`, `.svg`). They are not AI illustrations or direct database exports.
- `screenshots/`: genuine screenshots from my PostgreSQL/DbVisualizer and DBeaver sessions. The DbVisualizer graph was captured at 33% zoom; a full-resolution export can replace it later.
- `reports/`: published CSV summaries (not the complete 98,573-row source database).
- `charts/`: plots based on synthetic summary results.
- `data/`: only five demonstration customer rows; not used to produce the headline KPIs.
- `docs/`: findings, database notes, SQL skills and execution notes.

## Limitations

The original 98,573 synthetic records and the historical reporting view definitions live in the private StudioLens database on my Mac. The public queries include references to these views and cannot regenerate every headline result from this ZIP alone. The standalone demo in `database/03_standalone_sql_demo.sql` can be run separately.

The charts and screenshots are actual SQL result visuals or programmatic plots, not AI-generated database or studio illustrations.
