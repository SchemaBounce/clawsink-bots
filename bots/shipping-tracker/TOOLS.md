# Data Access

- Query `shipments`: `adl_query_records` — filter by tracking_number, carrier, status, or date range for lifecycle monitoring
- Query `delivery_slas`: `adl_query_records` — filter by shipping method and priority to get SLA thresholds
- Write `shipping_alerts`: `adl_upsert_record` — ID format `ship_alert_{tracking_number}`, required fields: tracking_number, carrier, status, exception_code, recommended_action
- Write `delivery_predictions`: `adl_upsert_record` — ID format `pred_{tracking_number}`, required fields: tracking_number, estimated_delivery, confidence, delay_risk

# Memory Usage

- `carrier_performance`: Historical delivery times and reliability metrics per carrier — use `adl_add_memory` to append completed shipment data
- `route_patterns`: Known delay corridors and seasonal patterns per route — use `adl_add_memory` when new patterns emerge

# Sub-Agent Orchestration

- `carrier-analyzer`: Delegates carrier performance comparison and reliability scoring
- `delay-predictor`: Delegates transit time prediction and delay probability calculation
- `exception-handler`: Delegates delivery exception classification and next-action recommendations
