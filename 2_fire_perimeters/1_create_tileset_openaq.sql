# bigquery
# Query to create the tileset on OpenAQ data of measurement points within 100 kilometers
# of the centroid of each wildfire polygon.

# Be sure to change [YOUR_PROJECT_NAME] to your actual project name on the lines marked # CHANGE ME

CALL cartobq.tiler.ST_PointAggregationAsMVT(
--SQL to use as the source (use geom as name for geography)
'''(
# Convert fire data into polygons.
with fire_data as (
SELECT
  safe.st_geogfromgeojson(geom) AS fire_polygon,
  incidentna AS incident_name,
  OBJECTID AS incident_id,
  CreateDate
FROM
  `[YOUR_PROJECT_NAME].geo.geo_dataset_nifs_perimeters`) # CHANGE ME

# Get all PM2.5 measurements within a specified radius of the centroid of each fire polygon.
SELECT
  coordinates.longitude as MEASUREMENT_LONGITUDE,
  coordinates.latitude as MEASUREMENT_LATITUDE,
  ST_GEOGPOINT(coordinates.longitude, coordinates.latitude) as MEASUREMENT_POINT,
  # EPA 2012 breakpoints for pm 2.5 over a 24h period
  # https://www.epa.gov/sites/production/files/2016-04/documents/2012_aqi_factsheet.pdf
  CASE
    WHEN value < 0      THEN STRUCT(0 as LEVEL, "negative value" as CATEGORY)
    WHEN value < 12     THEN STRUCT(1 as LEVEL, "Good (green 0 - 50)" as CATEGORY)
    WHEN value < 35.4   THEN STRUCT(2 as LEVEL, "2:Moderate (yellow 51 - 100)" as CATEGORY)
    WHEN value < 55.4   THEN STRUCT(3 as LEVEL, "Unhealthy for sensitive groups (orange 101 - 150)" as CATEGORY)
    WHEN value < 150.4  THEN STRUCT(4 as LEVEL, "Unhealthy (red 151 - 200)" as CATEGORY)
    WHEN value < 250.4  THEN STRUCT(5 as LEVEL, "Very healthy (dark red 201 - 300)" as CATEGORY)
    WHEN value < 350.4  THEN STRUCT(6 as LEVEL, "Hazardous (maroon 301 - 400)" as CATEGORY)
    WHEN value < 500    THEN STRUCT(7 as LEVEL, "7:Hazardous (maroon 401 - 500)" as CATEGORY)
    ELSE STRUCT(0 as LEVEL, "unexpected data" as CATEGORY)
  END AS PM25_CATEGORY,
  value as PM25_MEASUREMENT,
  date_utc as MEASUREMENT_DATE_UTC,
  fd.incident_id as FIRE_INCIDENT_ID,
  fd.incident_name as FIRE_INCIDENT_NAME, 
  fd.createdate as FIRE_INCIDENT_CREATE_DATE
FROM
  `[YOUR_PROJECT_NAME].geo.geo_dataset_openaq_demo` oaq, # CHANGE ME
  fire_data fd
WHERE
  oaq.parameter = "pm25"
  # Filter looking for measurements after the creation date of each fire.
  # This prunes out pre-fire measurements.
  AND CAST(oaq.date_utc AS DATE) >= 
    (SELECT CAST (createdate AS DATE) FROM fire_data WHERE incident_id = fd.incident_id)
  AND ST_DWITHIN(
    ST_GEOGPOINT(oaq.coordinates.longitude, oaq.coordinates.latitude),
    ST_CENTROID(fd.fire_polygon),
    100000) # Change me to set a different radius measurement.
)''',

--Name and location where the Tileset will be stored. Replace:
--acmecorp-282209.maps.nyc_tress_tileset with YOUR destination where --to store the TileSet.
  '`[YOUR_PROJECT_NAME].geo.tileset_openaq_wildfire`', # CHANGE ME

--Options on how to generate the Tileset
  '''{
      "geom_column": "MEASUREMENT_POINT",
      "zoom_max": 16,
      "type": "quadkey",
      "resolution": 8,
      "placement": "cell-centroid",
      "columns":{
        "aggregated_total": {
          "function": "count",
          "column": "*",
          "type": "Number"
        },
        "max_pm25_level": {
          "function": "max",
          "column": "PM25_CATEGORY.LEVEL",
          "type": "Number"
        },
        "max_pm25_measurement": {
          "function": "max",
          "column": "PM25_MEASUREMENT",
          "type": "Number"
        }
      }
 }''');
