# Business findings — from synthetic data

I analyzed a fictional photography studio using PostgreSQL. These are modeled outcomes, not real company results.

## Headline numbers

- **15,000 bookings**, including **11,700 completed bookings** and **1,800 cancelled bookings**.
- **₹378,515,300** net recognized revenue (about **₹37.85 crore**).
- **₹300,689,700** net cash collected after succeeded refunds.
- **₹77,825,600** modeled outstanding receivables.

## What stood out

**Wedding photography** generated the most revenue in the sample, **₹165,922,200 (43.84%)**. Corporate photography was next at **₹92,090,100 (24.33%)**. This tells me which categories are largest by *revenue*, but not which make the most profit: expenses have to be compared separately.

**Cancellations:** 1,800 / 15,000 bookings were cancelled, a simple 12% share. I did not label this the formal 30-day cancellation-rate KPI, because that requires separate cohort logic.

**Receivables:** There is a difference between completed-service revenue and cash received. The model leaves about ₹7.78 crore outstanding. In a real business, this would make aging and follow-up processes worth reviewing; here the result is from synthetic data.

## What I would investigate next

- Whether popular packages also have healthy profit margins.
- Whether cancellation reasons vary by service category.
- Which completed-booking customers return for more bookings.
- Whether overdue invoice follow-ups change collections.

## Data notes

The reporting cutoff is the end of October 2026 in Asia/Kolkata. The `reports/monthly_performance_34month_calendar.csv` file contains 32 directly exported activity months and two labeled, calendar-filled zero months. The private project has additional time-effective reporting logic and validation checks that are not included here.
