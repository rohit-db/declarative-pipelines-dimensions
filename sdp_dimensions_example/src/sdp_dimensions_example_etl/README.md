# SDP Dimensions Example ETL

Lakeflow Declarative Pipeline that creates a route dimension table from airline fare data.

## Pipeline Overview

This pipeline implements a medallion architecture:
1. **Bronze**: Ingests raw CSV files from volume
2. **Silver**: Creates deduplicated route dimension table using SCD Type 1

## Transformations

### `routes.sql`

Creates a route dimension table with:
- **Deterministic RouteSID**: MD5 hash of `Departure|Arrival`
- **Upsert Logic**: Uses `APPLY CHANGES` with SCD Type 1 semantics
- **Deduplication**: Keeps only the latest record per RouteSID

**Output Tables:**
- `bronze_fare`: Streaming table with raw fare data
- `silver_route_dim`: Dimension table with unique routes

## Running Transformations

### Using Workspace UI
- Open the transformation file and use `Run file` to preview

### Using CLI
```bash
databricks bundle run sdp_dimensions_example_etl --select routes
```

## Configuration

The pipeline uses these variables (set in `databricks.yml`):
- `${catalog}`: Target catalog
- `${schema}`: Target schema  
- `${volume}`: Volume path for source CSV files
