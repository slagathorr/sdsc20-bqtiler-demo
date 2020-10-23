# Quick Tutorial for the CARTO BigQuery Tiler
Hello, world! This is a tutorial on using the CARTO BigQuery Tiler with some basic visualizations. This will get you started on accessing tilesets in a couple different tools to help you learn some of the fundamentals.

## Read me first!
Few important notes before we begin.
- This is demonstration code that is meant to be used to learn, and isn't necessarily for use in production. It's not a supported product, so things may change and break over time, so we'll try to fix it when we can!
- This uses [Google BigQuery](https://cloud.google.com/bigquery) which can incur costs. Be sure to understand how costs will be incurred to your project through the [pricing page](https://cloud.google.com/bigquery/pricing), and be sure to understand the [Google Cloud Trial and Free Tiers](https://cloud.google.com/free) as well.
- This also uses the CARTO BigQuery Tiler. You need to be a part of the beta for this to work. Find more information on this [here](https://carto.com/bigquery/beta/).

## Load the data before starting this!
You will need to create a BigQuery dataset and will also need to load a couple tables before beginning.

### Some Housekeeping
- If this is your first time using Google Cloud, be sure to start your [free tial](https://cloud.google.com/free) and have your project created!
- For tasks done in the command line, you can leverage the [Cloud Shell](https://cloud.google.com/shell) which has the command line tools pre-installed, or you can [install the Google Cloud SDK](https://cloud.google.com/sdk/docs/install) to your local machine.
- In the command line, be sure to initialize things by running `gcloud auth login` to set your user, and `gcloud init` to set your default project.

### Create the BigQuery Dataset

After initializing your project, go ahead and create your dataset. The tutorial queries assume that you have named it "geo." Create that by running the following with the command line tools: `bq --location=US mk --dataset --description "Geospatial data for the Carto BQ Tiler Tutorial" geo`

### Create and load tables

Work in progress.

The queries will be added to this repository shortly after the presentation at [SDSC 20](https://spatial-data-science-conference.com/)!