-- StudioLens | 03: Revenue Analysis
-- Goal: Understand which services generate modeled recognized revenue.
-- Skills: SUM, ROUND, WHERE, JOIN, GROUP BY.
-- Note: Revenue is based on completed services, not cash payments.
-- The existing private database provides v_studiolens_bookings_asof.

-- A. Total recognized revenue through Oct 31, 2026 (IST).
SELECT ROUND(SUM(net_revenue_asof), 2) AS recognized_revenue_inr
FROM public.v_studiolens_bookings_asof
WHERE state_asof = 'Completed';

-- B. Revenue by photography category.
SELECT p.category,
       COUNT(*) AS completed_bookings,
       ROUND(SUM(v.net_revenue_asof), 2) AS revenue_inr
FROM public.v_studiolens_bookings_asof AS v
JOIN public.packages AS p
  ON v.package_id = p.package_id
WHERE v.state_asof = 'Completed'
GROUP BY p.category
ORDER BY revenue_inr DESC;

-- C. Monthly revenue for completed services.
SELECT DATE_TRUNC('month', v.completed_at AT TIME ZONE 'Asia/Kolkata')::date AS month,
       COUNT(*) AS completed_bookings,
       ROUND(SUM(v.net_revenue_asof), 2) AS revenue_inr
FROM public.v_studiolens_bookings_asof AS v
WHERE v.state_asof = 'Completed'
GROUP BY 1
ORDER BY 1;

-- D. Average recognized revenue per completed booking.
SELECT ROUND(
         SUM(net_revenue_asof) / NULLIF(COUNT(*), 0), 2
       ) AS avg_revenue_per_completed_booking_inr
FROM public.v_studiolens_bookings_asof
WHERE state_asof = 'Completed';
