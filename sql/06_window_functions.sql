-- StudioLens | A small advanced SQL showcase
-- These two queries are for learning; they do not change any records.
-- Skills: CTE, RANK, LAG. Works on the populated StudioLens database.

-- A. Rank the photography categories by recognized revenue.
-- A CTE first calculates one revenue total per category.
WITH category_revenue AS (
    SELECT p.category,
           SUM(v.net_revenue_asof) AS total_revenue
    FROM public.v_studiolens_bookings_asof AS v
    JOIN public.packages AS p ON v.package_id = p.package_id
    WHERE v.state_asof = 'Completed'
    GROUP BY p.category
)
SELECT category,
       ROUND(total_revenue, 2) AS revenue_inr,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_revenue
ORDER BY revenue_rank;

-- B. Compare one month with the previous month (months with completions).
WITH monthly_revenue AS (
    SELECT DATE_TRUNC('month', completed_at AT TIME ZONE 'Asia/Kolkata')::DATE AS month,
           SUM(net_revenue_asof) AS revenue
    FROM public.v_studiolens_bookings_asof
    WHERE state_asof = 'Completed'
    GROUP BY 1
)
SELECT month,
       ROUND(revenue, 2) AS revenue_inr,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS previous_reported_month_inr
FROM monthly_revenue
ORDER BY month;
-- Important: LAG compares to the preceding returned row, not necessarily
-- the preceding calendar month if zero-activity months are omitted.
