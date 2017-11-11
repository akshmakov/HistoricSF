HistoricSF
==========

**Live @ ** [http://historicsf.akshmakov.com](http://historicsf.akshmakov.com)

A hobby GIS Project To stitch together a large scale map of the San Francisco Bay Area from Historical Topographic Maps

Currently Published as an overlay tile set. The eventual goal is to produce a high quality base map for Historical and Historiagraphic Experimentation.


## Data Set

The Source Data is in the Public Domain. The Latest DataSet is available as a [release in github](https://github.com/akshmakov/HistoricSF/releases)

Historical Topographic Maps produced by the  U.S. Geological Survey.

Original Data Produced by the U.S. Geodetic Survey, prev United States Coast & Geodetic Survey and other Surveyors and Topographers including unaknowledged State Surveys



## Current Status of the Project.

- The Backend Processing Pipeline for Raw Data has been created, but is in Development and not publically  Released (used to generate the transformed source data)

  The pipeline automates the transformation and cropping of a large set of raster maps
  
- The initial dataset has been created and uploaded to github as a release

  - Dataset covers most of the region known as SF Bay Area

- An overlay map is published historicsf.akshmakov.com via github pages

- Color Correction and Graphical Tweaking has not been done.

## Next Steps

- Transform correction necessary (Map Alignment Errors)
- Release Processing Pipeline with Raw Data 
- Color Corection and Graphical Fixes


## How To Build

**Required Tools**

- GNU Make
- `gdalwarp`
- `gdaladdo`
- `gdalinfo`
- `gdal2tiles`


**Build CMD:** `make`