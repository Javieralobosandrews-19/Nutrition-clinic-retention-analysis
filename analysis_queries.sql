-- Data-Driven Nutrition
-- Consultas SQL utilizadas na análise de retenção e performance
-- Banco: SQLite | Dados simulados

-- ============================================================
-- ANALYTICAL QUERY
-- ============================================================
SELECT
    c.consultation_id,
    c.patient_id,
    c.nutritionist_id,
    c.consultation_date,
    c.consultation_type,
    c.attended,

    p.age,
    p.gender,
    p.city,
    p.goal,

    n.name AS nutritionist_name,
    n.specialty,

    pay.payment_id,
    pay.amount_brl,
    pay.payment_method

FROM consultations AS c

LEFT JOIN patients AS p
    ON c.patient_id = p.patient_id

LEFT JOIN nutritionists AS n
    ON c.nutritionist_id = n.nutritionist_id

LEFT JOIN payments AS pay
    ON c.consultation_id = pay.consultation_id;

-- ============================================================
-- SQL RELATIONSHIP VALIDATION QUERY
-- ============================================================
SELECT
    (
        SELECT COUNT(*)
        FROM consultations AS c
        LEFT JOIN patients AS p
            ON c.patient_id = p.patient_id
        WHERE p.patient_id IS NULL
    ) AS consultations_without_patient,

    (
        SELECT COUNT(*)
        FROM consultations AS c
        LEFT JOIN nutritionists AS n
            ON c.nutritionist_id = n.nutritionist_id
        WHERE n.nutritionist_id IS NULL
    ) AS consultations_without_nutritionist,

    (
        SELECT COUNT(*)
        FROM consultations AS c
        LEFT JOIN payments AS p
            ON c.consultation_id = p.consultation_id
        WHERE p.payment_id IS NULL
    ) AS consultations_without_payment;

-- ============================================================
-- ATTENDANCE QUERY
-- ============================================================
SELECT
    COUNT(*) AS total_consultations,
    SUM(attended) AS attended_consultations,
    COUNT(*) - SUM(attended) AS missed_consultations,
    ROUND(100.0 * SUM(attended) / COUNT(*),
        2
    ) AS attendance_rate
FROM consultations;

-- ============================================================
-- CONSULTATIONS PER PATIENT QUERY
-- ============================================================
SELECT
    patient_id,
    COUNT(*) AS total_consultations,
    SUM(attended) AS attended_consultations
FROM consultations
GROUP BY patient_id
ORDER BY total_consultations DESC;

-- ============================================================
-- REVENUE BY PAYMENT QUERY
-- ============================================================
SELECT
    payment_method,
    COUNT(*) AS total_payments,
    SUM(amount_brl) AS total_revenue,
    ROUND(AVG(amount_brl), 2) AS average_payment
FROM payments
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- ============================================================
-- REVENUE BY ATTENDANCE QUERY
-- ============================================================
SELECT
    CASE
        WHEN c.attended = 1 THEN 'Compareceu'
        ELSE 'Não compareceu'
    END AS attendance_status,
    COUNT(*) AS total_consultations,
    SUM(p.amount_brl) AS total_revenue,
    ROUND(AVG(p.amount_brl), 2) AS average_payment
FROM consultations AS c

LEFT JOIN payments AS p
    ON c.consultation_id = p.consultation_id

GROUP BY c.attended
ORDER BY c.attended DESC;

-- ============================================================
-- REVENUE METHOD ATTENDANCE QUERY
-- ============================================================
SELECT
    p.payment_method,
    CASE
        WHEN c.attended = 1 THEN 'Compareceu'
        ELSE 'Não compareceu'
    END AS attendance_status,
    COUNT(*) AS total_consultations,
    SUM(p.amount_brl) AS total_revenue
FROM consultations AS c

LEFT JOIN payments AS p
    ON c.consultation_id = p.consultation_id

GROUP BY
    p.payment_method,
    c.attended

ORDER BY
    p.payment_method,
    c.attended DESC;

-- ============================================================
-- PATIENT RETENTION QUERY
-- ============================================================
WITH first_consultation AS (
    SELECT
        patient_id,
        MIN(DATE(consultation_date)) AS first_consultation_date
    FROM consultations
    WHERE consultation_type = 'Primeira'
      AND attended = 1
    GROUP BY patient_id
),

first_return AS (
    SELECT
        c.patient_id,
        MIN(DATE(c.consultation_date)) AS first_return_date
    FROM consultations AS c

    INNER JOIN first_consultation AS f
        ON c.patient_id = f.patient_id

    WHERE c.consultation_type = 'Retorno'
      AND c.attended = 1
      AND DATE(c.consultation_date) >
          DATE(f.first_consultation_date)

    GROUP BY c.patient_id
),

retention_base AS (
    SELECT
        f.patient_id,
        f.first_consultation_date,
        r.first_return_date,

        CAST(
            JULIANDAY(r.first_return_date)
            - JULIANDAY(f.first_consultation_date)
            AS INTEGER
        ) AS days_to_first_return

    FROM first_consultation AS f

    LEFT JOIN first_return AS r
        ON f.patient_id = r.patient_id
)

SELECT
    patient_id,
    first_consultation_date,
    first_return_date,
    days_to_first_return,

    CASE
        WHEN days_to_first_return BETWEEN 1 AND 30
        THEN 1
        ELSE 0
    END AS retained_30_days,

    CASE
        WHEN days_to_first_return BETWEEN 1 AND 60
        THEN 1
        ELSE 0
    END AS retained_60_days,

    CASE
        WHEN days_to_first_return BETWEEN 1 AND 90
        THEN 1
        ELSE 0
    END AS retained_90_days

FROM retention_base

ORDER BY patient_id;

