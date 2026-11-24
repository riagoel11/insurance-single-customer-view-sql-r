-- ============================================================================
-- Initial SQL analysis on the Analytics Base Table (Microsoft Access SQL)
-- Transcribed from the query screenshots in Appendix 2 of the report.
-- The table numbers refer to the outputs in Section 2.4 of the report.
--
-- Note: the ABT itself was built in Access by LEFT JOINing the Motor, Health
-- and Travel policy tables onto the Customer table (CustomerID primary key;
-- MotorID, HealthID, TravelID foreign keys). That query is not included here.
-- ============================================================================


-- Table 1: Count of policy holders of each insurance type
SELECT
    COUNT(MotorID) AS Total_Motor_Policies,
    COUNT(HealthID) AS Total_Health_Policies,
    COUNT(TravelID) AS Total_Travel_Policies
FROM
    AnalyticsBaseTable


-- Table 2: Distribution of insurance types by communication channel
SELECT
    ComChannel,
    SUM(IIF(MotorID IS NOT NULL, 1, 0)) AS Motor_yes,
    SUM(IIF(MotorID IS NULL, 1, 0)) AS Motor_no,
    SUM(IIF(HealthID IS NOT NULL, 1, 0)) AS Health_yes,
    SUM(IIF(HealthID IS NULL, 1, 0)) AS Health_no,
    SUM(IIF(TravelID IS NOT NULL, 1, 0)) AS Travel_yes,
    SUM(IIF(TravelID IS NULL, 1, 0)) AS Travel_no
FROM
    AnalyticsBaseTable
GROUP BY
    ComChannel
ORDER BY
    ComChannel;


-- Table 3: Percent distribution of types of motor insurance
SELECT
    MotorType,
    COUNT(*) AS num_motor,
    COUNT(*) * 100.0 / (
        SELECT
            COUNT(*)
        FROM
            AnalyticsBaseTable
    ) AS percentage
FROM
    AnalyticsBaseTable
WHERE
    MotorID IS NOT NULL
GROUP BY
    MotorType;


-- Table 4: Percent distribution of types of travel insurance
SELECT
    TravelType,
    COUNT(*) AS num_travel,
    COUNT(*) * 100.0 / (
        SELECT
            COUNT(*)
        FROM
            AnalyticsBaseTable
    ) AS percentage
FROM
    AnalyticsBaseTable
WHERE
    TravelID IS NOT NULL
GROUP BY
    TravelType;


-- Table 5: Customer distribution by health type
SELECT
    HealthType,
    COUNT(*) AS num_health
FROM
    AnalyticsBaseTable
WHERE
    HealthID IS NOT NULL
GROUP BY
    HealthType;


-- Table 6: Average age by insurance type
SELECT
    'Motor' AS Insurance_Type,
    AVG(Age) AS Avg_Age
FROM
    AnalyticsBaseTable
WHERE
    MotorID IS NOT NULL
UNION ALL
SELECT
    'Health' AS Insurance_Type,
    AVG(Age) AS Avg_Age
FROM
    AnalyticsBaseTable
WHERE
    HealthID IS NOT NULL
UNION ALL
SELECT
    'Travel' AS Insurance_Type,
    AVG(Age) AS Avg_Age
FROM
    AnalyticsBaseTable
WHERE
    TravelID IS NOT NULL;


-- Table 7: Insurance level by minimum and maximum age (surfaced invalid ages)
SELECT
    'Health' AS Category,
    HealthType AS Insurance_Level,
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM
    AnalyticsBaseTable
WHERE
    HealthType IS NOT NULL
GROUP BY
    HealthType
UNION ALL
SELECT
    'Motor' AS Category,
    MotorType AS Insurance_Level,
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM
    AnalyticsBaseTable
WHERE
    MotorType IS NOT NULL
GROUP BY
    MotorType
UNION ALL
SELECT
    'Travel' AS Category,
    TravelType AS Insurance_Level,
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM
    AnalyticsBaseTable
WHERE
    TravelType IS NOT NULL
GROUP BY
    TravelType;
