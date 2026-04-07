---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: shopify
  displayName: "Shopify"
  version: "1.0.0"
  description: "Shopify e-commerce — products, orders, inventory, and customer management"
  tags: ["shopify", "ecommerce", "inventory", "orders", "products"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "shopify-mcp@1.0.8"]
env:
  - name: SHOPIFY_ACCESS_TOKEN
    description: "Shopify Admin API access token"
    required: true
  - name: SHOPIFY_STORE_DOMAIN
    description: "Your store domain e.g. your-store.myshopify.com"
    required: true
tools:
  - name: list_products
    description: "List products"
    category: products
  - name: get_product
    description: "Get product details"
    category: products
  - name: create_product
    description: "Create a product"
    category: products
  - name: update_product
    description: "Update product details"
    category: products
  - name: list_orders
    description: "List orders"
    category: orders
  - name: get_order
    description: "Get order details"
    category: orders
  - name: create_order
    description: "Create a draft order"
    category: orders
  - name: list_inventory
    description: "List inventory levels"
    category: inventory
  - name: update_inventory
    description: "Adjust inventory quantity"
    category: inventory
  - name: list_customers
    description: "List customers"
    category: customers
  - name: get_customer
    description: "Get customer details"
    category: customers
  - name: search_products
    description: "Search products by query"
    category: products
---

# Shopify MCP Server

Provides Shopify Admin API tools for bots that manage e-commerce products, orders, inventory, and customers.

## Which Bots Use This

- **inventory-tracker** -- Monitors stock levels, triggers reorder alerts, and adjusts inventory quantities
- **accountant** -- Reconciles orders and revenue against financial records
- **customer-support** -- Looks up order status and customer details for support inquiries

## Setup

1. Create a Shopify Custom App in your store's admin (Settings > Apps and sales channels > Develop apps)
2. Grant Admin API access scopes: `read_products`, `write_products`, `read_orders`, `write_orders`, `read_inventory`, `write_inventory`, `read_customers`
3. Add `SHOPIFY_ACCESS_TOKEN` and `SHOPIFY_STORE_DOMAIN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Shopify server instance across e-commerce bots:

```yaml
mcpServers:
  - ref: "tools/shopify"
    reason: "E-commerce bots need Shopify access for inventory, orders, and customer data"
    config:
      store_domain: "your-store.myshopify.com"
```
