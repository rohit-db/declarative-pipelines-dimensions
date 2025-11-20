# SDP Dimensions Example

A Databricks Asset Bundle project for creating route dimension tables using Lakeflow Declarative Pipelines.

## Project Structure

- `src/`: Python source code and SQL transformations
- `resources/`: Databricks resource configurations (jobs, pipelines)

## Configuration

The project uses variables defined in `databricks.yml`:
- `catalog`: Target catalog (default: `rohitb_demo`)
- `schema`: Target schema (default: `sdp_airlines`)
- `volume`: Volume for raw data (default: `flight_data`)

## Deployment

### Prerequisites

1. Authenticate to your Databricks workspace:
   ```bash
   databricks configure
   ```

### Deploy to Development

```bash
databricks bundle deploy --target dev
```

This deploys:
- Pipeline: `[dev yourname] sdp_dimensions_example_etl`
- Job: `[dev yourname] sample_job` (scheduled daily, paused in dev mode)

### Deploy to Production

```bash
databricks bundle deploy --target prod
```

### Run a Job

```bash
databricks bundle run
```

## Resources

- **Pipeline**: `sdp_dimensions_example_etl` - Creates route dimension table from fare data
- **Job**: `sample_job` - Generates dummy data and triggers pipeline refresh

## Documentation

- [Databricks Asset Bundles](https://docs.databricks.com/dev-tools/bundles/index.html)
- [Lakeflow Declarative Pipelines](https://docs.databricks.com/dlt)
