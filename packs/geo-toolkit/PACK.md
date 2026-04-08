---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: geo-toolkit
  displayName: Geospatial Toolkit
  version: 1.0.0
  description: Geocoding, distance calculation, routing, and geofence operations
  category: Geospatial
  tags: [distance, geofence, address, routing, timezone, coordinates]
  icon: globe
tools:
  - name: geocode
    description: Convert an address to latitude/longitude coordinates or reverse geocode coordinates to an address
    category: geocoding
  - name: distance_calculate
    description: Calculate the distance between two geographic points using Haversine formula
    category: calculation
  - name: timezone_from_location
    description: Determine the timezone for given latitude/longitude coordinates
    category: lookup
  - name: address_parse
    description: Parse a free-form address string into structured components (street, city, state, zip, country)
    category: parsing
  - name: route_optimize
    description: Find the optimal ordering for visiting multiple waypoints to minimize total distance
    category: optimization
  - name: geofence_check
    description: Check whether a point falls inside or outside a defined geographic boundary
    category: spatial
---

# Geospatial Toolkit

Geocoding, distance calculation, routing, and geofence operations. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent working with location data, logistics, or geographic analysis.

## Use Cases

- Calculate distances between warehouse and delivery locations
- Parse free-form addresses into structured components
- Optimize delivery routes across multiple stops
- Check whether a GPS coordinate falls within a service area
- Determine timezone from coordinates for scheduling

## Tools

### geocode
Convert a street address to latitude/longitude coordinates, or reverse geocode coordinates back to a human-readable address.

### distance_calculate
Compute the great-circle distance between two geographic points using the Haversine formula. Returns distance in km or miles.

### timezone_from_location
Look up the IANA timezone identifier for a given latitude/longitude coordinate pair.

### address_parse
Parse an unstructured address string into components: street number, street name, city, state/province, postal code, and country.

### route_optimize
Given a list of waypoints with coordinates, find the ordering that minimizes total travel distance using nearest-neighbor heuristics.

### geofence_check
Test whether a point (lat/lng) is inside a polygon-defined geofence boundary. Returns inside/outside with distance to nearest edge.
