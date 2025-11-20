# Declarative Pipelines Dimensions Example

A Databricks project demonstrating dimension table creation using Lakeflow Declarative Pipelines with SCD Type 1 (Slowly Changing Dimension) logic.

## Overview

This project creates a route dimension table from airline fare data using:
- **Lakeflow Declarative Pipelines** for streaming ETL
- **SCD Type 1** semantics for deduplication and updates
- **Deterministic route IDs** using MD5 hashing

## Project Structure

```
sdp_dimensions_example/
├── resources/              # Databricks bundle configurations
│   ├── sample_job.job.yml # Scheduled job (generates data + runs pipeline)
│   └── sdp_dimensions_example_etl.pipeline.yml
├── src/
│   ├── generate_data/     # Notebook to generate dummy flight data
│   └── sdp_dimensions_example_etl/
│       └── transformations/
│           └── routes.sql # Route dimension table definition
└── databricks.yml         # Bundle configuration
```

## Key Features

- **Bronze Layer**: Ingests raw CSV files from a volume
- **Silver Layer**: Creates a deduplicated route dimension table
- **Upsert Logic**: Uses `APPLY CHANGES` with SCD Type 1 to maintain latest records
- **Deterministic Keys**: RouteSID generated from Departure + Arrival using MD5

## Quick Start

See [sdp_dimensions_example/README.md](sdp_dimensions_example/README.md) for deployment and usage instructions.
