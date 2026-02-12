WITH activity_gaps AS (
    SELECT
        user_id,
        activity_date,
        LAG(activity_date) OVER (
            PARTITION BY user_id
            ORDER BY activity_date
        ) AS previous_activity
    FROM user_activity
),

gap_calculation AS (
    SELECT
        user_id,
        activity_date,
        DATE_DIFF(
            'day',
            previous_activity,
            activity_date
        ) AS inactive_days
    FROM activity_gaps
),

user_status AS (
    SELECT
        user_id,
        MAX(inactive_days) AS max_inactive_gap,
        CASE
            WHEN MAX(inactive_days) >= 30 THEN 1
            ELSE 0
        END AS reengaged_flag
    FROM gap_calculation
    GROUP BY user_id
)

SELECT
    COUNT(*) AS total_users,
    SUM(reengaged_flag) AS reengaged_users,
    ROUND(
        SUM(reengaged_flag) * 100.0 / COUNT(*),
        2
    ) AS reengagement_rate_percentage
FROM user_status;
