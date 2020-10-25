# Quick Tutorial for the CARTO BigQuery Tiler
Hello, world! This is a tutorial on using the CARTO BigQuery Tiler with some basic visualizations. This will get you started on accessing tilesets in a couple different tools to help you learn some of the fundamentals.

## Read me first!
Some important notes and housekeeping before we begin.
- This is demonstration code that is meant to be used to learn, and isn't necessarily for use in production. It's not a supported product, so things may change and break over time, so we'll try to fix it when we can!
- If this is your first time using Google Cloud, be sure to start your [free trial](https://cloud.google.com/free) and have your project created!
- This uses [Google BigQuery](https://cloud.google.com/bigquery) which can incur costs. Be sure to understand how costs will be incurred to your project through the [pricing page](https://cloud.google.com/bigquery/pricing), and be sure to understand the [Google Cloud Trial and Free Tiers](https://cloud.google.com/free) as well.
- This also uses the CARTO BigQuery Tiler. You need to be a part of the beta for this to work. Find more information on this [here](https://carto.com/bigquery/beta/).
- For tasks done in the command line, you can leverage the [Cloud Shell](https://cloud.google.com/shell) which has the command line tools pre-installed, or you can [install the Google Cloud SDK](https://cloud.google.com/sdk/docs/install) to your local machine.
- In the command line, be sure to initialize things by running `gcloud auth login` to set your user, and `gcloud init` to set your default project.

## Load the data before starting this!
You will need to create a BigQuery dataset and will also need to load a couple tables before beginning.

### Create the BigQuery Dataset

After initializing your project, go ahead and create your dataset. The tutorial queries assume that you have named it "geo." Create that by running the following with the command line tool:

```bq --location=US mk --dataset --description "Geospatial data for the Carto BQ Tiler Tutorial" geo```

### Create and load tables
#### National Interagency Fire Center Data

You will now be loading in a dataset containing polygons representing the wildfires in the United States. This will be using a snapshot from October 19, 2020, from the [National Interagency Fire Center](https://data-nifc.opendata.arcgis.com/). The file export used in this tutorial are the [shapefiles](https://data-nifc.opendata.arcgis.com/datasets/wildfire-perimeters) available for download.

The snapshot is in the `data` path in this repository, and the filename is `Wildfire_Perimeters-shp.zip`.

First, make sure to downoad the [GDAL tools](https://gdal.org/), which is a translator library for geospatial data, and the unzip tool. You can do this with the following command:

`sudo apt-get install gdal-bin unzip`

From the `data` path, run the following commands:

```
unzip Wildfire_Perimeters-shp.zip
ogr2ogr -f csv -dialect sqlite -sql "select AsGeoJSON(geometry) as geom, * from Public_NIFS_Perimeters" nifs_perimeters.csv Public_NIFS_Perimeters.shp
```

This will output a CSV file called `nifs_perimeters.csv` which contains the fire geography data. When creating a new table, you can directly upload a file through the browser interface to load data, but that has a limit of 10 megabytes. For anything larger, a common way to load data is from a Google Cloud Storage (GCS) bucket. You'll be uploading this to GCS and then loading it into a BigQuery table, while having BigQuery try and [automatically determine the column types](https://cloud.google.com/bigquery/docs/schema-detect).

Note: GCS uses a global namespace, so be sure to pick a unique name when choosing what to name your bucket.

```
mybucket=[YOUR BUCKET NAME HERE]
gsutil mb gs://$mybucket
gsutil cp nifs_perimeters.csv gs://$mybucket
bq load --autodetect --replace geo.geo_dataset_nifs_perimeters gs://$mybucket/nifs_perimeters.csv
```

You can now take a look at this dataset with the following query:

```
SELECT
  ST_GEOGFROMGEOJSON(geom) AS GEOGRAPHY,
  *
FROM
  geo.geo_dataset_nifs_perimeters
LIMIT
  10
```

The queries will be added to this repository shortly after the presentation at [SDSC 20](https://spatial-data-science-conference.com/)!