# bigquery
# This adds a column of type GEOGRAPHY which is a point of the 
# centroid of all polygons in planet_features in the OpenStreetMap dataset
# in which the tags mark it as a type of building.

# If you want to write this out to a permanent table, follow the directions 
# according to your preferred query interface to do so at:
# https://cloud.google.com/bigquery/docs/writing-results#console

# Note that this tutorial assumes you will name this table 
# 'geo_dataset_osm_planet_features_buildings' in a dataset called 'geo'
# in your project.

SELECT
  ST_CENTROID(geometry) AS geom,
  *
FROM
  `bigquery-public-data.geo_openstreetmap.planet_features`,
  UNNEST(all_tags) AS tags
WHERE
  tags.key = 'building'
  AND geometry IS NOT NULL
# Comment out the next line to remove the 20 row limit.
# Doing so processes the entire planet_features table.
LIMIT 20;