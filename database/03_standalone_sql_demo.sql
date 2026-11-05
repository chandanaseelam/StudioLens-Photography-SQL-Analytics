-- StudioLens | A small SQL demo that anyone can run in PostgreSQL.
-- Uses only temporary tables and fictional records.
-- It DOES NOT create, edit, or delete any of the 12 public StudioLens tables.
-- Run as ONE SQL script in DBeaver, in the same database connection.
-- The ROLLBACK at the end removes this practice data.

BEGIN;

-- STEP 1: Build a tiny, independent example (3 linked tables).
CREATE TEMP TABLE demo_customers (
    customer_id VARCHAR(12) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL
) ON COMMIT DROP;

CREATE TEMP TABLE demo_packages (
    package_id VARCHAR(12) PRIMARY KEY,
    package_name VARCHAR(80) NOT NULL,
    category VARCHAR(30) NOT NULL
) ON COMMIT DROP;

CREATE TEMP TABLE demo_bookings (
    booking_id VARCHAR(12) PRIMARY KEY,
    customer_id VARCHAR(12) NOT NULL REFERENCES demo_customers(customer_id),
    package_id VARCHAR(12) NOT NULL REFERENCES demo_packages(package_id),
    completed_on DATE,
    booking_status VARCHAR(20) NOT NULL,
    agreed_price NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0
) ON COMMIT DROP;

-- STEP 2: Insert fictional demo data.
INSERT INTO demo_customers VALUES
('D001', 'Aarav Sharma', 'Hyderabad'),
('D002', 'Priya Reddy', 'Bengaluru'),
('D003', 'Meera Rao', 'Chennai'),
('D004', 'Rahul Verma', 'Hyderabad'),
('D005', 'Kavya Nair', 'Pune');

INSERT INTO demo_packages VALUES
('P01', 'Wedding Standard', 'Wedding'),
('P02', 'Portrait Basic', 'Portrait'),
('P03', 'Corporate Standard', 'Corporate');

INSERT INTO demo_bookings VALUES
('B001','D001','P01','2026-01-14','Completed',40000,1000),
('B002','D002','P02','2026-01-21','Completed',6500,0),
('B003','D001','P02','2026-02-09','Completed',6500,500),
('B004','D003','P03','2026-02-19','Completed',22000,1000),
('B005','D004','P01',NULL,'Cancelled',40000,0),
('B006','D002','P03','2026-03-07','Completed',22000,0),
('B007','D005','P02','2026-03-10','Completed',6500,500),
('B008','D001','P03','2026-03-22','Completed',22000,1000),
('B009','D003','P01',NULL,'Pending',40000,0),
('B010','D004','P02','2026-03-30','Completed',6500,0);

-- STEP 3: Basic SELECT and aggregation.
SELECT booking_status, COUNT(*) AS bookings
FROM demo_bookings
GROUP BY booking_status
ORDER BY bookings DESC;

-- STEP 4: JOIN + GROUP BY. This is modeled sales value for completed services.
SELECT p.category,
       COUNT(*) AS completed_bookings,
       SUM(b.agreed_price - b.discount_amount) AS modeled_revenue
FROM demo_bookings AS b
JOIN demo_packages AS p ON p.package_id = b.package_id
WHERE b.booking_status = 'Completed'
GROUP BY p.category
ORDER BY modeled_revenue DESC;

-- STEP 5: CTE + HAVING: which customers returned for a completed booking?
WITH customer_bookings AS (
    SELECT c.customer_id, c.customer_name, COUNT(*) AS completed_count
    FROM demo_customers AS c
    JOIN demo_bookings AS b ON b.customer_id = c.customer_id
    WHERE b.booking_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, completed_count
FROM customer_bookings
WHERE completed_count >= 2
ORDER BY completed_count DESC;

-- STEP 6: Window functions: rank categories by completed revenue.
WITH category_totals AS (
    SELECT p.category, SUM(b.agreed_price-b.discount_amount) AS revenue
    FROM demo_bookings b
    JOIN demo_packages p ON p.package_id=b.package_id
    WHERE b.booking_status='Completed'
    GROUP BY p.category
)
SELECT category, revenue,
       RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM category_totals
ORDER BY revenue_rank;

-- STEP 7: Another window function: month vs previous reported month.
WITH monthly AS (
    SELECT DATE_TRUNC('month', completed_on)::DATE AS month,
           SUM(agreed_price-discount_amount) AS revenue
    FROM demo_bookings
    WHERE booking_status='Completed'
    GROUP BY 1
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
FROM monthly
ORDER BY month;

-- STEP 8: Leave the connected StudioLens project unchanged.
ROLLBACK;
