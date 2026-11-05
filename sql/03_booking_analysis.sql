-- StudioLens | 02: Booking Analysis
-- Goal: Explore demand and booking outcomes for a fictional photo studio.
-- Skills: WHERE, COUNT, GROUP BY, JOIN, ORDER BY.
-- These are descriptive booking counts, not the approved 30-day cohort cancellation KPI.

-- A. Overall booking status distribution.
SELECT booking_status,
       COUNT(*) AS booking_count
FROM public.bookings
GROUP BY booking_status
ORDER BY booking_count DESC;

-- B. Booking volume by photography category.
-- Join each booking with its package to find its category.
SELECT p.category,
       COUNT(*) AS total_bookings
FROM public.bookings AS b
JOIN public.packages AS p
  ON b.package_id = p.package_id
GROUP BY p.category
ORDER BY total_bookings DESC;

-- C. Monthly completed-booking trend through the approved cutoff.
-- The reporting view excludes inappropriate post-cutoff state assumptions.
SELECT DATE_TRUNC('month', completed_at AT TIME ZONE 'Asia/Kolkata')::date AS month,
       COUNT(*) AS completed_bookings
FROM public.v_studiolens_bookings_asof
WHERE state_asof = 'Completed'
GROUP BY 1
ORDER BY 1;

-- D. Why did bookings get cancelled?
SELECT reason_code,
       COUNT(*) AS cancelled_bookings
FROM public.cancellations
WHERE cancelled_at < TIMESTAMPTZ '2026-11-01 00:00:00+05:30'
GROUP BY reason_code
ORDER BY cancelled_bookings DESC;

-- E. Bookings by customer city.
SELECT c.city,
       COUNT(*) AS total_bookings
FROM public.bookings AS b
JOIN public.customers AS c
  ON b.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_bookings DESC;
