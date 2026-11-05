# How the tables connect

I used 12 tables for this simulated photography studio database. The center of the analysis is `bookings`, which links each customer to a photography package. Bookings can also connect to photographer assignments, invoices, cancellations, reviews, and direct expenses.

The diagrams in `diagrams/` were **generated programmatically from the initial CREATE TABLE file**. It is a schematic of table relationships and selected attributes—not a screenshot of the live database or a full physical schema export. The working local database has additional migration fields, constraints, views, and triggers.

The source diagrams are included as `.dot` files so they can be reviewed or regenerated. If I later export a graph directly from DbVisualizer, I can replace the PNG without changing the SQL.

### PK and FK examples

- `customers.customer_id` is the primary key of the customers table.
- `bookings.customer_id` points to `customers.customer_id`.
- `bookings.package_id` points to `packages.package_id`.
- `payments.invoice_id` points to `invoices.invoice_id`.

This design lets me analyze bookings, packages and customers together without treating two people with the same name as one customer.
