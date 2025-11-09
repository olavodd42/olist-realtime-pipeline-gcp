SELECT
  TIMESTAMP_TRUNC(event_time, MINUTE) AS minute,
  category,
  COUNT(DISTINCT order_id) AS orders,
  SUM(price * qty) AS revenue
FROM {{ ref('stg_orders') }}
GROUP BY 1,2
ORDER BY 1 DESC
