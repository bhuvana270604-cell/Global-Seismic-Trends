-- Global Seismic Trends
-- SQL analysis queries for the GUVI project
-- Database: global_seismic_trends
-- Table: earthquakes
-- Note: These are queries only; result outputs are not stored in this file.

USE global_seismic_trends;

-- 1. Inspect table structure
DESCRIBE earthquakes;

-- 2. Top 10 strongest earthquakes
SELECT time, place,
       CAST(mag AS DECIMAL(10,2)) AS magnitude,
       CAST(depth AS DECIMAL(10,2)) AS depth_km,
       magType
FROM earthquakes
WHERE mag IS NOT NULL AND mag <> ''
ORDER BY CAST(mag AS DECIMAL(10,2)) DESC
LIMIT 10;

-- 3. Top 10 deepest earthquakes
SELECT time, place,
       CAST(mag AS DECIMAL(10,2)) AS magnitude,
       CAST(depth AS DECIMAL(10,2)) AS depth_km
FROM earthquakes
WHERE depth IS NOT NULL AND depth <> ''
  AND CAST(depth AS DECIMAL(10,2)) > 0
ORDER BY CAST(depth AS DECIMAL(10,2)) DESC
LIMIT 10;

-- 4. Shallow, high-magnitude earthquakes (magnitude > 7.5, depth < 70 km)
SELECT time, place,
       CAST(mag AS DECIMAL(10,2)) AS magnitude,
       CAST(depth AS DECIMAL(10,2)) AS depth_km
FROM earthquakes
WHERE mag IS NOT NULL AND mag <> ''
  AND depth IS NOT NULL AND depth <> ''
  AND CAST(mag AS DECIMAL(10,2)) > 7.5
  AND CAST(depth AS DECIMAL(10,2)) < 70
ORDER BY CAST(mag AS DECIMAL(10,2)) DESC;

-- 5. Earthquake count and average magnitude by magnitude type
SELECT magType,
       COUNT(*) AS earthquake_count,
       ROUND(AVG(CAST(mag AS DECIMAL(10,2))), 2) AS average_magnitude
FROM earthquakes
WHERE magType IS NOT NULL AND magType <> ''
  AND mag IS NOT NULL AND mag <> ''
GROUP BY magType
ORDER BY average_magnitude DESC;

-- 6. Year with the most earthquake records
SELECT year, COUNT(*) AS earthquake_count
FROM earthquakes
WHERE year IS NOT NULL AND year <> ''
GROUP BY year
ORDER BY earthquake_count DESC
LIMIT 1;

-- 7. Month with the most earthquake records
SELECT month, month_name, COUNT(*) AS earthquake_count
FROM earthquakes
WHERE month IS NOT NULL AND month <> ''
GROUP BY month, month_name
ORDER BY earthquake_count DESC
LIMIT 1;

-- 8. Day of week with the most earthquake records
SELECT DAYNAME(STR_TO_DATE(LEFT(time, 19), '%Y-%m-%d %H:%i:%s')) AS day_of_week,
       COUNT(*) AS earthquake_count
FROM earthquakes
WHERE time IS NOT NULL AND time <> ''
GROUP BY day_of_week
ORDER BY earthquake_count DESC
LIMIT 1;

-- 9. Earthquake counts by hour of day
SELECT HOUR(STR_TO_DATE(LEFT(time, 19), '%Y-%m-%d %H:%i:%s')) AS hour_of_day,
       COUNT(*) AS earthquake_count
FROM earthquakes
WHERE time IS NOT NULL AND time <> ''
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 10. Reporting network with the most records
SELECT net AS reporting_network, COUNT(*) AS earthquake_count
FROM earthquakes
WHERE net IS NOT NULL AND net <> ''
GROUP BY net
ORDER BY earthquake_count DESC
LIMIT 1;

-- 11. Earthquake records by status
SELECT status, COUNT(*) AS earthquake_count
FROM earthquakes
WHERE status IS NOT NULL AND status <> ''
GROUP BY status
ORDER BY earthquake_count DESC;

-- 12. Earthquake records by event type
SELECT type AS earthquake_type, COUNT(*) AS earthquake_count
FROM earthquakes
WHERE type IS NOT NULL AND type <> ''
GROUP BY type
ORDER BY earthquake_count DESC;

-- 13. Most common data types listed in the types field
SELECT types AS data_type, COUNT(*) AS earthquake_count
FROM earthquakes
WHERE types IS NOT NULL AND types <> ''
GROUP BY types
ORDER BY earthquake_count DESC
LIMIT 10;

-- 14. Events with station count greater than 100
SELECT time, place,
       CAST(mag AS DECIMAL(10,2)) AS magnitude,
       CAST(nst AS UNSIGNED) AS station_count
FROM earthquakes
WHERE nst IS NOT NULL AND nst <> ''
  AND CAST(nst AS UNSIGNED) > 100
ORDER BY CAST(nst AS UNSIGNED) DESC;

-- 15. Year-over-year earthquake count and growth rate
WITH yearly_counts AS (
    SELECT CAST(year AS UNSIGNED) AS earthquake_year,
           COUNT(*) AS total_earthquakes
    FROM earthquakes
    WHERE year IS NOT NULL AND year <> ''
    GROUP BY CAST(year AS UNSIGNED)
),
yearly_growth AS (
    SELECT earthquake_year, total_earthquakes,
           LAG(total_earthquakes) OVER (ORDER BY earthquake_year) AS previous_year_count
    FROM yearly_counts
)
SELECT earthquake_year, total_earthquakes, previous_year_count,
       ROUND((total_earthquakes - previous_year_count) * 100.0
             / NULLIF(previous_year_count, 0), 2) AS growth_rate_percent
FROM yearly_growth
ORDER BY earthquake_year;

-- 16. Three most frequent place labels and average magnitude
SELECT place AS region,
       COUNT(*) AS earthquake_count,
       ROUND(AVG(CAST(mag AS DECIMAL(10,2))), 2) AS average_magnitude
FROM earthquakes
WHERE place IS NOT NULL AND place <> ''
  AND mag IS NOT NULL AND mag <> ''
GROUP BY place
ORDER BY earthquake_count DESC
LIMIT 3;

-- 17. Earthquakes between 5 degrees south and 5 degrees north latitude
SELECT COUNT(*) AS earthquake_count,
       ROUND(AVG(CAST(depth AS DECIMAL(10,2))), 2) AS average_depth_km
FROM earthquakes
WHERE latitude IS NOT NULL AND latitude <> ''
  AND CAST(latitude AS DECIMAL(10,6)) BETWEEN -5 AND 5
  AND depth IS NOT NULL AND depth <> '';

-- 18. Shallow-to-deep earthquake ratio by place label
SELECT place AS region,
       SUM(CASE WHEN CAST(depth AS DECIMAL(10,2)) <= 70 THEN 1 ELSE 0 END) AS shallow_count,
       SUM(CASE WHEN CAST(depth AS DECIMAL(10,2)) > 300 THEN 1 ELSE 0 END) AS deep_count,
       ROUND(
           SUM(CASE WHEN CAST(depth AS DECIMAL(10,2)) <= 70 THEN 1 ELSE 0 END) /
           NULLIF(SUM(CASE WHEN CAST(depth AS DECIMAL(10,2)) > 300 THEN 1 ELSE 0 END), 0),
           2
       ) AS shallow_deep_ratio
FROM earthquakes
WHERE place IS NOT NULL AND place <> ''
  AND depth IS NOT NULL AND depth <> ''
GROUP BY place
HAVING deep_count > 0
ORDER BY shallow_deep_ratio DESC
LIMIT 5;

-- 19. Average gap and RMS by place label (at least 10 records)
SELECT place AS region,
       COUNT(*) AS earthquake_count,
       ROUND(AVG(CAST(gap AS DECIMAL(10,2))), 2) AS avg_gap,
       ROUND(AVG(CAST(rms AS DECIMAL(10,3))), 3) AS avg_rms
FROM earthquakes
WHERE place IS NOT NULL AND place <> ''
  AND gap IS NOT NULL AND gap <> ''
  AND rms IS NOT NULL AND rms <> ''
GROUP BY place
HAVING COUNT(*) >= 10
ORDER BY avg_gap DESC, avg_rms DESC
LIMIT 10;

-- 20. Consecutive records within 50 km and one hour of each other.
-- This compares consecutive rows ordered by time; it does not prove they are the same event.
WITH earthquake_pairs AS (
    SELECT time, place,
           CAST(latitude AS DECIMAL(10,6)) AS latitude,
           CAST(longitude AS DECIMAL(10,6)) AS longitude,
           CAST(mag AS DECIMAL(10,2)) AS magnitude,
           LEAD(time) OVER (ORDER BY time) AS next_time,
           LEAD(place) OVER (ORDER BY time) AS next_place,
           LEAD(CAST(latitude AS DECIMAL(10,6))) OVER (ORDER BY time) AS next_latitude,
           LEAD(CAST(longitude AS DECIMAL(10,6))) OVER (ORDER BY time) AS next_longitude,
           LEAD(CAST(mag AS DECIMAL(10,2))) OVER (ORDER BY time) AS next_magnitude
    FROM earthquakes
    WHERE time IS NOT NULL AND time <> ''
      AND latitude IS NOT NULL AND latitude <> ''
      AND longitude IS NOT NULL AND longitude <> ''
),
distances AS (
    SELECT *,
           6371 * 2 * ASIN(SQRT(
               POWER(SIN(RADIANS(next_latitude - latitude) / 2), 2) +
               COS(RADIANS(latitude)) * COS(RADIANS(next_latitude)) *
               POWER(SIN(RADIANS(next_longitude - longitude) / 2), 2)
           )) AS distance_km
    FROM earthquake_pairs
    WHERE next_time IS NOT NULL
)
SELECT time AS first_time, place AS first_place,
       next_time AS second_time, next_place AS second_place,
       ROUND(distance_km, 2) AS distance_km,
       TIMESTAMPDIFF(
           MINUTE,
           STR_TO_DATE(time, '%Y-%m-%d %H:%i:%s.%f'),
           STR_TO_DATE(next_time, '%Y-%m-%d %H:%i:%s.%f')
       ) AS minutes_apart
FROM distances
WHERE distance_km <= 50
  AND TIMESTAMPDIFF(
      SECOND,
      STR_TO_DATE(time, '%Y-%m-%d %H:%i:%s.%f'),
      STR_TO_DATE(next_time, '%Y-%m-%d %H:%i:%s.%f')
  ) BETWEEN 0 AND 3600
ORDER BY distance_km ASC
LIMIT 20;

-- 21. Potential repeated records by time, place, latitude, longitude
SELECT time, place, latitude, longitude, COUNT(*) AS record_count
FROM earthquakes
GROUP BY time, place, latitude, longitude
HAVING COUNT(*) > 1
ORDER BY record_count DESC
LIMIT 20;

-- 22. Potential repeated records using additional event fields
SELECT time, place, latitude, longitude, depth, mag, magType, status,
       COUNT(*) AS record_count
FROM earthquakes
GROUP BY time, place, latitude, longitude, depth, mag, magType, status
HAVING COUNT(*) > 1;

-- 23. Compare total rows to distinct concatenated field values.
-- CONCAT_WS skips NULL values; this is a practical check, not a perfect full-row duplicate test.
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT CONCAT_WS(
           '|', time, updated, latitude, longitude, depth, mag, magType, place,
           status, nst, gap, dmin, rms, net, locationSource, type, ids, sources,
           types, year, month, month_name, depth_category
       )) AS distinct_rows
FROM earthquakes;
