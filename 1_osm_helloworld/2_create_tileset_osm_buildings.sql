# bigquery
/*
  Running this will call the CARTO BigQuery Tiler to process your table.
  This assumes that you have created a table in your BigQuery project called
  'geo.geo_dataset_osm_planet_features_buildings' from previously running 1_geo_process_osm_buildings.sql
  and will create a Tileset called 'geo.tileset_osm_planet_features_buildings'.
  */

CALL
  cartobq.tiler.ST_PointAggregationAsMVT(
    --SQL to use as the source (use geom as name for geography)
    '''(SELECT 
          geog_centroid as geom
        FROM 
          `[PROJECT].geo.geo_dataset_osm_planet_features_buildings`)''', # CHANGE ME
    
    --Name and location where the Tileset will be stored. Replace with YOUR destination
    --where to store the TileSet.
    '`[PROJECT].geo.tileset_osm_planet_features_buildings`', # CHANGE ME
    
    --Options on how to generate the Tileset
    '''{
      "zoom_max": 16,
      "type": "quadkey",
      "resolution": 8,
      "placement": "cell-centroid",
      "columns":{
        "aggregated_total": {
          "function": "count",
          "column": "*",
          "type": "Number"
        }
      }
 }''');