WITH base AS (
  SELECT
    event_id, event_time, order_id, customer_id, currency, total_value, source,
    JSON_QUERY_ARRAY(items) AS items
  FROM `{{ target.project }}.ecommerce_raw.orders_stream`
)
SELECT
  event_id, event_time, order_id, customer_id, currency, total_value, source,
  CAST(JSON_VALUE(it, '$.product_id') AS STRING)   AS product_id,
  CAST(JSON_VALUE(it, '$.category')   AS STRING)   AS category,
  CAST(JSON_VALUE(it, '$.price')      AS FLOAT64)  AS price,
  CAST(JSON_VALUE(it, '$.qty')        AS INT64)    AS qty
FROM base, UNNEST(items) AS it
