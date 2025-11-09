SELECT
  order_id,
  MIN(event_time) AS order_time,
  ANY_VALUE(customer_id) AS customer_id,
  SUM(price * qty) AS order_value
FROM {{ ref('stg_orders') }}
GROUP BY order_id
