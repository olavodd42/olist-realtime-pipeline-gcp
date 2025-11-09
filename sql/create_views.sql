-- KPIs por minuto
CREATE OR REPLACE VIEW `${PROJECT_ID}.ecommerce_raw.v_orders_minute` AS
SELECT
  TIMESTAMP_TRUNC(event_time, MINUTE) AS minute,
  COUNT(*) AS orders,
  SUM(total_value) AS revenue
FROM `${PROJECT_ID}.ecommerce_raw.orders_stream`
GROUP BY 1
ORDER BY 1 DESC;

-- KPIs por categoria por minuto (assumindo items JSON; se STRING, use PARSE_JSON(items))
CREATE OR REPLACE VIEW `${PROJECT_ID}.ecommerce_raw.v_orders_by_category_minute` AS
SELECT
  TIMESTAMP_TRUNC(event_time, MINUTE) AS minute,
  JSON_VALUE(i, '$.category') AS category,
  COUNT(*) AS orders,
  SUM(CAST(JSON_VALUE(i,'$.price') AS FLOAT64) * CAST(JSON_VALUE(i,'$.qty') AS INT64)) AS revenue
FROM `${PROJECT_ID}.ecommerce_raw.orders_stream`,
UNNEST(JSON_QUERY_ARRAY(items)) AS i
GROUP BY 1,2
ORDER BY 1 DESC;

