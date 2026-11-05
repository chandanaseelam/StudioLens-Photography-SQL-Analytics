-- StudioLens | Basic CRUD practice (Create, Read, Update, Delete)
-- This whole exercise uses a PostgreSQL TEMPORARY TABLE.
-- It doesn't insert, update, or delete records in public.customers.
-- Run the whole script in ONE DBeaver SQL Editor connection.
-- ROLLBACK removes the practice table and any changes made in this exercise.

BEGIN;

CREATE TEMP TABLE studiolens_crud_practice (
    customer_id VARCHAR(12) PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) UNIQUE,
    city VARCHAR(80)
) ON COMMIT DROP;

-- CREATE: Add two fictional customers.
INSERT INTO studiolens_crud_practice (customer_id, customer_name, email, city)
VALUES
    ('DEMO001', 'Aarav Sharma', 'aarav.demo001@example.com', 'Hyderabad'),
    ('DEMO002', 'Priya Reddy', 'priya.demo002@example.com', 'Chennai');

-- READ: Check the inserted records.
SELECT * FROM studiolens_crud_practice ORDER BY customer_id;

-- UPDATE: Fix the city for the second fictional customer.
UPDATE studiolens_crud_practice
SET city = 'Bengaluru'
WHERE customer_id = 'DEMO002';

SELECT * FROM studiolens_crud_practice ORDER BY customer_id;

-- DELETE: Remove only one practice row.
DELETE FROM studiolens_crud_practice
WHERE customer_id = 'DEMO001';

SELECT * FROM studiolens_crud_practice ORDER BY customer_id;

-- Exit without saving any practice changes.
ROLLBACK;
