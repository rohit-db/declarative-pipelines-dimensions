-- Lakeflow Declarative Pipelines: Route Dimension Table Creation and Upsert Logic
-- This workflow ingests raw fare data, generates a deterministic route ID, and maintains a deduplicated dimension table using SCD Type 1 semantics.

-- Step 1: Ingest raw fare data as a streaming table (bronze layer)
-- The _metadata.file_path is captured for traceability.
CREATE OR REFRESH STREAMING TABLE bronze_fare
AS SELECT *, _metadata.file_path AS source_file
FROM STREAM read_files('/Volumes/${catalog}/${schema}/${volume}/*.csv', format => 'csv');

-- Step 2: Prepare a temporary streaming view to generate a deterministic RouteSID
-- This view filters out records with null Departure or Arrival and generates a unique RouteSID using MD5 hash.
CREATE TEMPORARY STREAMING LIVE VIEW stream_route_source AS
SELECT 
  -- Generate a deterministic surrogate key for the route
  md5(concat_ws('|', Departure, Arrival)) AS RouteSID, 
  Departure, 
  Arrival,
  current_timestamp() as LastSeen -- Timestamp for sequencing and upsert logic
FROM STREAM(LIVE.bronze_fare)
WHERE Departure IS NOT NULL AND Arrival IS NOT NULL;

-- Step 3: Define the target dimension table (silver layer) for routes (SCD Type 1)
CREATE OR REFRESH STREAMING TABLE silver_route_dim (
  RouteSID STRING,
  Departure STRING,
  Arrival STRING,
  LastSeen TIMESTAMP
);

-- Step 4: Apply upsert (SCD Type 1) logic to deduplicate and update the dimension table
APPLY CHANGES INTO LIVE.silver_route_dim
FROM STREAM(LIVE.stream_route_source)
KEYS (RouteSID) -- The unique key for upsert
SEQUENCE BY LastSeen -- Use LastSeen to determine the latest record
STORED AS SCD TYPE 1; -- Type 1: overwrite/update, no history tracking

-- Step 3 (SCD2): Define the target dimension table for routes (SCD Type 2)
-- Do NOT declare the schema explicitly for SCD2 tables, as system columns (__START_AT, __END_AT) are automatically added.
CREATE OR REFRESH STREAMING TABLE silver_route_dim_scd2; -- SCD2 table without explicit schema declaration

-- Step 4 (SCD2): Apply upsert (SCD Type 2) logic to deduplicate and update the dimension table
APPLY CHANGES INTO LIVE.silver_route_dim_scd2
FROM STREAM(LIVE.stream_route_source)
KEYS (RouteSID) -- The unique key for upsert
SEQUENCE BY LastSeen -- Use LastSeen to determine the latest record
STORED AS SCD TYPE 2; -- Type 2: History tracking