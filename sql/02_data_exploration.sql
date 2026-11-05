-- StudioLens | 01: Data Exploration
-- Goal: Understand what data is available in our photography studio.
-- Read-only: these SELECT statements do not change any tables.
-- Requirements: existing studiolens_db database, public schema.

-- A. How many customers are recorded?
SELECT COUNT(*) AS total_customers
FROM public.customers;

-- B. How many bookings exist, and what are their statuses?
SELECT booking_status,
       COUNT(*) AS number_of_bookings
FROM public.bookings
GROUP BY booking_status
ORDER BY number_of_bookings DESC;

-- C. Which cities have the most registered customers?
SELECT city, COUNT(*) AS registered_customers
FROM public.customers
GROUP BY city
ORDER BY registered_customers DESC;

-- D. Which photography categories and packages are offered?
SELECT category,
       COUNT(*) AS available_packages
FROM public.packages
WHERE is_active = TRUE
GROUP BY category
ORDER BY category;

-- E. How many customers are classified as individuals or businesses?
SELECT customer_type, COUNT(*) AS customers
FROM public.customers
GROUP BY customer_type
ORDER BY customers DESC;
