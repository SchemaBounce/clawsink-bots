---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: ecommerce-toolkit
  displayName: E-commerce Toolkit
  version: 1.0.0
  description: Pricing, SKU generation, shipping, inventory, and cart calculations
  category: E-commerce
  tags: [pricing, sku, shipping, inventory, cart, margin, loyalty]
  icon: cart
tools:
  - name: calculate_pricing
    description: Calculate final price with discounts, tax, and promotional rules
    category: pricing
  - name: generate_sku
    description: Generate standardized SKU codes from product attributes
    category: catalog
  - name: calculate_shipping
    description: Estimate shipping cost based on weight, dimensions, and destination
    category: shipping
  - name: inventory_check
    description: Check stock levels and flag items below reorder thresholds
    category: inventory
  - name: cart_total
    description: Calculate cart total with line items, quantities, discounts, and tax
    category: pricing
  - name: product_categorize
    description: Classify a product into a taxonomy based on title and attributes
    category: classification
  - name: margin_calculator
    description: Calculate profit margin from cost, selling price, and overhead
    category: analysis
  - name: loyalty_points
    description: Calculate loyalty points earned or redeemed for a transaction
    category: loyalty
---

# E-commerce Toolkit

Pricing, SKU generation, shipping, inventory, and cart calculations. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent managing online stores, product catalogs, or order processing.

## Use Cases

- Calculate cart totals with multi-tier discounts and tax
- Generate consistent SKU codes for new products
- Estimate shipping costs across different carriers and zones
- Flag inventory items that need restocking
- Compute profit margins across product lines

## Tools

### calculate_pricing
Compute final price from base price, percentage or fixed discounts, tax rate, and promotional rules.

### generate_sku
Build standardized SKU codes from product category, brand, color, size, and variant attributes.

### calculate_shipping
Estimate shipping cost using weight, dimensions, origin, destination, and carrier rate tables.

### inventory_check
Query stock levels for items and return current quantity, reorder status, and estimated restock date.

### cart_total
Sum line items with quantities, apply item-level and cart-level discounts, compute tax, and return the final total.

### product_categorize
Classify a product into a hierarchical taxonomy based on title, description, and attribute keywords.

### margin_calculator
Calculate gross margin, markup percentage, and net margin from cost, selling price, and overhead inputs.

### loyalty_points
Compute loyalty points earned from a purchase amount or calculate the discount value of redeemed points.
