-- StudioLens | Data checking and cleaning concepts
-- Run in the EXISTING populated studiolens_db.
-- READ-ONLY: these statements do not modify customer or booking data.
-- The raw synthetic data is not claimed to contain or require cleaning.

-- 1. Missing email and contact information.
SELECT COUNT(*) AS customers_missing_email
FROM public.customers
WHERE email IS NULL OR TRIM(email) = '';

-- 2. Duplicated customer emails (a shared name is NOT a duplicate customer).
SELECT LOWER(TRIM(email)) AS normalized_email,
       COUNT(*) AS number_of_customers
FROM public.customers
WHERE email IS NOT NULL
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;

-- 3. Standardize text for reporting, without updating stored values.
SELECT customer_id,
       TRIM(customer_name) AS clean_customer_name,
       LOWER(TRIM(email)) AS clean_email,
       COALESCE(NULLIF(TRIM(city), ''), 'Unknown') AS reporting_city
FROM public.customers
ORDER BY customer_id
LIMIT 10;

-- 4. Validate booking-to-customer and booking-to-package relationships.
SELECT COUNT(*) AS bookings_missing_customer_or_package
FROM public.bookings b
LEFT JOIN public.customers c ON b.customer_id = c.customer_id
LEFT JOIN public.packages p ON b.package_id = p.package_id
WHERE c.customer_id IS NULL OR p.package_id IS NULL;

-- 5. Completed bookings should have a completion timestamp.
SELECT COUNT(*) AS completed_without_date
FROM public.bookings
WHERE booking_status = 'Completed' AND completed_at IS NULL;

-- 6. Demonstrate CASE WHEN for descriptive status labels.
SELECT booking_id,
       booking_status,
       CASE
           WHEN booking_status = 'Completed' THEN 'Finished'
           WHEN booking_status = 'Cancelled' THEN 'Cancelled'
           ELSE 'Not completed'
       END AS status_group
FROM public.bookings
ORDER BY booking_id
LIMIT 10;
