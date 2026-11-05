-- StudioLens | Database structure reference (12 tables)
-- This is the original, initial CREATE TABLE design; the working private
-- PostgreSQL database also has a later migration, reporting views and a trigger.
-- This script alone will NOT recreate the private 98,573-row project.
-- IMPORTANT: Run ONLY in a NEW EMPTY PostgreSQL database if learning setup.
-- Do NOT run it in your already populated studiolens_db.
-- No credentials, real customer data or DROP/TRUNCATE commands are included.

-- StudioLens Photography Business & Revenue Analytics
-- Phase 2, Lesson 2.7: initial 12-table PostgreSQL schema
-- Run in studiolens_db, not the default postgres database.
-- Existing tables are skipped by IF NOT EXISTS: this does NOT repair an existing table.
-- No DROP TABLE, TRUNCATE, or data deletion commands.

-- Confirm which database is connected before running the script:
SELECT current_database() AS connected_database;

-- 1. customers
CREATE TABLE IF NOT EXISTS public.customers (
    customer_id VARCHAR(12) PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(80),
    customer_type VARCHAR(20) NOT NULL DEFAULT 'Individual',
    signup_date DATE NOT NULL,
    CONSTRAINT chk_customer_type CHECK (customer_type IN ('Individual', 'Business')),
    CONSTRAINT chk_customer_contact CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

-- 2. photographers
CREATE TABLE IF NOT EXISTS public.photographers (
    photographer_id VARCHAR(12) PRIMARY KEY,
    photographer_name VARCHAR(120) NOT NULL,
    specialty VARCHAR(60),
    hire_date DATE NOT NULL,
    employment_type VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT chk_employment_type CHECK (employment_type IN ('Full-Time', 'Part-Time', 'Freelance')),
    CONSTRAINT chk_photographer_status CHECK (status IN ('Active', 'Inactive'))
);

-- 3. packages
CREATE TABLE IF NOT EXISTS public.packages (
    package_id VARCHAR(12) PRIMARY KEY,
    package_name VARCHAR(120) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    list_price NUMERIC(12,2) NOT NULL,
    duration_hours NUMERIC(5,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_package_price CHECK (list_price >= 0),
    CONSTRAINT chk_package_duration CHECK (duration_hours > 0)
);

-- 4. bookings
CREATE TABLE IF NOT EXISTS public.bookings (
    booking_id VARCHAR(12) PRIMARY KEY,
    customer_id VARCHAR(12) NOT NULL,
    package_id VARCHAR(12) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    event_start_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    booking_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    agreed_price NUMERIC(12,2),
    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    service_credit_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    notes TEXT,
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id),
    CONSTRAINT fk_booking_package FOREIGN KEY (package_id) REFERENCES public.packages(package_id),
    CONSTRAINT chk_booking_status CHECK (booking_status IN ('Pending', 'Confirmed', 'Completed', 'Cancelled', 'No_Show')),
    CONSTRAINT chk_booking_price CHECK (agreed_price >= 0),
    CONSTRAINT chk_booking_discount CHECK (discount_amount >= 0),
    CONSTRAINT chk_service_credit CHECK (service_credit_amount >= 0),
    CONSTRAINT chk_booking_dates CHECK (event_start_at >= created_at),
    CONSTRAINT chk_completion_date CHECK (completed_at IS NULL OR completed_at >= event_start_at),
    CONSTRAINT chk_completed_booking CHECK (booking_status <> 'Completed' OR completed_at IS NOT NULL),
    CONSTRAINT chk_confirmed_price CHECK (booking_status NOT IN ('Confirmed', 'Completed') OR agreed_price IS NOT NULL),
    CONSTRAINT chk_revenue_adjustments CHECK (agreed_price IS NULL OR discount_amount + service_credit_amount <= agreed_price)
);

-- 5. booking_assignments
CREATE TABLE IF NOT EXISTS public.booking_assignments (
    assignment_id VARCHAR(12) PRIMARY KEY,
    booking_id VARCHAR(12) NOT NULL,
    photographer_id VARCHAR(12) NOT NULL,
    assignment_start_at TIMESTAMPTZ NOT NULL,
    assignment_end_at TIMESTAMPTZ NOT NULL,
    assigned_hours NUMERIC(6,2) NOT NULL,
    assignment_status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT fk_assignment_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id),
    CONSTRAINT fk_assignment_photographer FOREIGN KEY (photographer_id) REFERENCES public.photographers(photographer_id),
    CONSTRAINT chk_assignment_hours CHECK (assigned_hours > 0),
    CONSTRAINT chk_assignment_dates CHECK (assignment_end_at > assignment_start_at),
    CONSTRAINT chk_assignment_status CHECK (assignment_status IN ('Scheduled', 'Completed', 'Cancelled'))
);

-- 6. invoices
CREATE TABLE IF NOT EXISTS public.invoices (
    invoice_id VARCHAR(12) PRIMARY KEY,
    booking_id VARCHAR(12) NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL,
    due_date DATE NOT NULL,
    invoice_amount NUMERIC(12,2) NOT NULL,
    credit_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    invoice_status VARCHAR(20) NOT NULL DEFAULT 'Draft',
    currency_code CHAR(3) NOT NULL DEFAULT 'INR',
    CONSTRAINT fk_invoice_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id),
    CONSTRAINT chk_invoice_amount CHECK (invoice_amount >= 0),
    CONSTRAINT chk_invoice_credit CHECK (credit_amount >= 0 AND credit_amount <= invoice_amount),
    CONSTRAINT chk_invoice_status CHECK (invoice_status IN ('Draft', 'Issued', 'Partially_Paid', 'Paid', 'Voided')),
    CONSTRAINT chk_invoice_currency CHECK (currency_code = 'INR')
);

-- 7. payments
CREATE TABLE IF NOT EXISTS public.payments (
    payment_id VARCHAR(12) PRIMARY KEY,
    invoice_id VARCHAR(12) NOT NULL,
    original_payment_id VARCHAR(12),
    transaction_type VARCHAR(20) NOT NULL,
    payment_at TIMESTAMPTZ NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    external_reference VARCHAR(80) UNIQUE,
    CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id),
    CONSTRAINT fk_original_payment FOREIGN KEY (original_payment_id) REFERENCES public.payments(payment_id),
    CONSTRAINT chk_transaction_type CHECK (transaction_type IN ('Payment', 'Refund')),
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT chk_payment_status CHECK (status IN ('Pending', 'Succeeded', 'Failed')),
    CONSTRAINT chk_original_payment CHECK ((transaction_type = 'Payment' AND original_payment_id IS NULL) OR (transaction_type = 'Refund' AND original_payment_id IS NOT NULL)),
    CONSTRAINT chk_no_self_refund CHECK (original_payment_id IS NULL OR original_payment_id <> payment_id)
);

-- 8. expenses
CREATE TABLE IF NOT EXISTS public.expenses (
    expense_id VARCHAR(12) PRIMARY KEY,
    booking_id VARCHAR(12),
    expense_date DATE NOT NULL,
    expense_category VARCHAR(60) NOT NULL,
    cost_type VARCHAR(20) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    description TEXT,
    CONSTRAINT fk_expense_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id),
    CONSTRAINT chk_cost_type CHECK (cost_type IN ('Direct', 'Indirect')),
    CONSTRAINT chk_expense_amount CHECK (amount >= 0),
    CONSTRAINT chk_direct_expense CHECK (cost_type <> 'Direct' OR booking_id IS NOT NULL)
);

-- 9. package_price_history
CREATE TABLE IF NOT EXISTS public.package_price_history (
    price_id VARCHAR(12) PRIMARY KEY,
    package_id VARCHAR(12) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    price NUMERIC(12,2) NOT NULL,
    CONSTRAINT fk_price_package FOREIGN KEY (package_id) REFERENCES public.packages(package_id),
    CONSTRAINT chk_history_price CHECK (price >= 0),
    CONSTRAINT chk_history_dates CHECK (effective_to IS NULL OR effective_to > effective_from)
);

-- 10. cancellations
CREATE TABLE IF NOT EXISTS public.cancellations (
    cancellation_id VARCHAR(12) PRIMARY KEY,
    booking_id VARCHAR(12) NOT NULL UNIQUE,
    cancelled_at TIMESTAMPTZ NOT NULL,
    reason_code VARCHAR(40) NOT NULL,
    reason_details TEXT,
    initiated_by VARCHAR(20) NOT NULL,
    CONSTRAINT fk_cancellation_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id),
    CONSTRAINT chk_cancel_initiator CHECK (initiated_by IN ('Customer', 'Studio'))
);

-- 11. reviews
CREATE TABLE IF NOT EXISTS public.reviews (
    review_id VARCHAR(12) PRIMARY KEY,
    booking_id VARCHAR(12) NOT NULL,
    photographer_id VARCHAR(12),
    feedback_category VARCHAR(30) NOT NULL,
    rating SMALLINT,
    review_text TEXT,
    reviewed_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES public.bookings(booking_id),
    CONSTRAINT fk_review_photographer FOREIGN KEY (photographer_id) REFERENCES public.photographers(photographer_id),
    CONSTRAINT chk_feedback_category CHECK (feedback_category IN ('Service', 'Photographer', 'Equipment', 'Scheduling', 'Other')),
    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5)
);

-- 12. photographer_availability
CREATE TABLE IF NOT EXISTS public.photographer_availability (
    availability_id VARCHAR(12) PRIMARY KEY,
    photographer_id VARCHAR(12) NOT NULL,
    available_date DATE NOT NULL,
    available_hours NUMERIC(5,2) NOT NULL,
    availability_type VARCHAR(20) NOT NULL DEFAULT 'Regular',
    CONSTRAINT fk_availability_photographer FOREIGN KEY (photographer_id) REFERENCES public.photographers(photographer_id),
    CONSTRAINT chk_available_hours CHECK (available_hours >= 0 AND available_hours <= 24),
    CONSTRAINT chk_availability_type CHECK (availability_type IN ('Regular', 'Overtime', 'Special'))
);

-- Verification: list expected and missing tables
WITH expected_tables(name) AS (
    VALUES ('customers'), ('photographers'), ('packages'), ('bookings'),
           ('booking_assignments'), ('invoices'), ('payments'), ('expenses'),
           ('package_price_history'), ('cancellations'), ('reviews'),
           ('photographer_availability')
)
SELECT e.name AS table_name,
       CASE WHEN t.table_name IS NULL THEN 'MISSING' ELSE 'EXISTS' END AS status
FROM expected_tables e
LEFT JOIN information_schema.tables t
  ON t.table_schema = 'public'
 AND t.table_type = 'BASE TABLE'
 AND t.table_name = e.name
ORDER BY e.name;

-- Verification: review all declared primary/foreign/unique/check constraints
SELECT conrelid::regclass AS table_name,
       conname AS constraint_name,
       pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY table_name, constraint_name;
