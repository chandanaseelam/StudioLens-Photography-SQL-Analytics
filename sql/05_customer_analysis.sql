-- StudioLens | 04: Customer Analysis
-- Goal: Identify active customers and repeat customers.
-- Skills: JOIN, GROUP BY, HAVING, CTE, COUNT.
-- IMPORTANT: A repeat customer has 2+ COMPLETED bookings under the same
-- customer_id. Two people sharing a name are not the same customer.

-- A. How many distinct customers made any booking?
SELECT COUNT(DISTINCT customer_id) AS customers_with_bookings
FROM public.bookings;

-- B. Customers with two or more completed bookings.
SELECT customer_id,
       COUNT(*) AS completed_bookings
FROM public.v_studiolens_bookings_asof
WHERE state_asof = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY completed_bookings DESC, customer_id
LIMIT 20;

-- C. Repeat customer rate among customers with completed bookings.
WITH customer_completions AS (
    SELECT customer_id,
           COUNT(*) AS completed_bookings
    FROM public.v_studiolens_bookings_asof
    WHERE state_asof = 'Completed'
    GROUP BY customer_id
)
SELECT COUNT(*) AS customers_with_completed_bookings,
       COUNT(*) FILTER (WHERE completed_bookings >= 2) AS repeat_customers,
       ROUND(
           100.0 * COUNT(*) FILTER (WHERE completed_bookings >= 2)
           / NULLIF(COUNT(*), 0), 2
       ) AS repeat_customer_rate_pct
FROM customer_completions;

-- D. Customer registration by city.
SELECT city,
       COUNT(*) AS registered_customers
FROM public.customers
GROUP BY city
ORDER BY registered_customers DESC;
