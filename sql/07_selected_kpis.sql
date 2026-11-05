-- StudioLens | 05: Selected Business KPIs
-- Entry-level portfolio: a focused selection, NOT certification of all 16
-- KPIs in the private project.
-- All queries are read-only. Values are from synthetic records.

-- KPI A: Total bookings created through the reporting cutoff.
SELECT COUNT(*) AS total_bookings
FROM public.v_studiolens_bookings_asof;

-- KPI B: Number of completed bookings through the reporting cutoff.
SELECT COUNT(*) AS completed_bookings
FROM public.v_studiolens_bookings_asof
WHERE state_asof = 'Completed';

-- KPI C: Total recognized revenue.
SELECT ROUND(SUM(net_revenue_asof), 2) AS revenue_inr
FROM public.v_studiolens_bookings_asof
WHERE state_asof = 'Completed';

-- KPI D: Average revenue per completed booking.
SELECT ROUND(
    SUM(net_revenue_asof) / NULLIF(COUNT(*), 0), 2
) AS average_booking_revenue_inr
FROM public.v_studiolens_bookings_asof
WHERE state_asof = 'Completed';

-- KPI E: Cash collected after refunds through cutoff (not revenue).
SELECT ROUND(SUM(net_cash), 2) AS net_cash_collected_inr
FROM public.v_studiolens_invoices_asof;

-- KPI F: Outstanding receivables, based on the time-effective invoice view.
SELECT ROUND(SUM(outstanding_ar), 2) AS outstanding_receivables_inr
FROM public.v_studiolens_invoices_asof;

-- KPI G: Average valid customer rating through cutoff.
SELECT ROUND(AVG(rating::numeric), 2) AS avg_customer_rating
FROM public.reviews
WHERE rating BETWEEN 1 AND 5
  AND reviewed_at < TIMESTAMPTZ '2026-11-01 00:00:00+05:30';

-- The straightforward cancelled-booking share (1800/15000) is NOT the
-- approved cancellation-rate KPI: that uses matured 30-day booking cohorts.
-- See README for why we do not publish it as a formal KPI here.
