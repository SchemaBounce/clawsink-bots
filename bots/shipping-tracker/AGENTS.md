# Escalation

- Delivery status updates (delivered, delayed, exception, returned): finding to order-fulfillment
- Systemic carrier failures affecting multiple shipments: alert to executive-assistant

# Persistent Learning

- Store actual delivery times per carrier in `carrier_performance` memory after every completed shipment to build statistical baselines for delay detection
- Store route-specific delay patterns in `route_patterns` memory when consistent corridor delays emerge (e.g., 2-day delays on a specific route)
