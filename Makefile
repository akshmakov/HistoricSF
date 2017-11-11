#!/usr/bin/env make
# HistoricSF Makefile
#
#
# Configurable Variables
# prefix - install root
# bindir - script install dir
#



##################################
### Global Variables #############
##################################

TOP_DIR ?= $(shell pwd)
DATA_ROOT_DIR ?= $(TOP_DIR)/project_data
DATA_GROUP ?= historicsf
DATA_SOURCE ?= raw
DATA_DIR ?= $(DATA_ROOT_DIR)/$(DATA_GROUP)/$(DATA_SOURCE)
OUT_ROOT ?= $(TOP_DIR)/output/$(DATA_GROUP)
OUT_DIR ?= $(OUT_ROOT)/$(DATA_SOURCE)

CALC_FILTER_DIR ?= $(TOP_DIR)/calc_filters
CALC_NAME ?= default
CALC_FILTER_FILE ?= $(CALC_FILTER_DIR)/$(CALC_NAME).inc
CALC_DIR ?= $(OUT_DIR)/calc/$(CALC_NAME)

DATA_SOURCE_TYPE ?= tif



RASTER2PGSQL ?= raster2pgsql
RASTER2PGSQL_OPTS ?= -d -C -M -F -I -t auto  -l 2,4,8,16,32,64,128,256

S3CMD ?= s3cmd
## Break Convention, must end in "/"
S3_ROOT_PATH ?= s3://
S3_GROUP_PATH ?= $(S3_ROOT_PATH)$(DATA_GROUP)/
S3_OUT_PATH ?= $(S3_GROUP_PATH)$(DATA_SOURCE)/

GDALWARP ?= gdalwarp
GDALINFO    ?= gdalinfo
GDALADDO    ?= gdaladdo
GDAL2TILES  ?= gdal2tiles.py

GDALADDO_LADDER ?= 2 4 8 16 32 64 128 256 512
GDAL_ZOOM_LEVELS ?= '2-18'

TARGET_CRS ?= EPSG:3857

# Raw Sources are GEOPDF
DATA_FILES ?= $(shell ls $(DATA_DIR)/*.$(DATA_SOURCE_TYPE))
_DATA_FILEN := $(basename $(notdir $(DATA_FILES)) )


#Tifs converted to target crs
#output/group/source/image.tif
TIF_FILES = $(addprefix $(OUT_DIR)/, $(addsuffix .tif, $(_DATA_FILEN)) )

#Generate convenience infor dump
#output/group/source/image.info
INFO_FILES = $(addprefix $(OUT_DIR)/, $(addsuffix .info, $(_DATA_FILEN)) )

#Tile Sets (CAUTION VERY LARGE)
#output/group/source/tiles/image/
TILE_TARGETS = $(addprefix $(OUT_DIR)/tiles/, $(_DATA_FILEN) $(addsuffix .cropped, $(_DATA_FILEN)))


all: tif tile merge merge-tile info
.PHONY: all


$(OUT_DIR):
	mkdir -p $@



ifeq ($(DATA_SOURCE_TYPE),tif)
$(OUT_DIR)/%.tif:$(DATA_DIR)/%.tif
	cp $< $@
	$(GDALADDO) $@ $(GDALADDO_LADDER)
else
$(OUT_DIR)/%.tif:$(DATA_DIR)/%.pdf
	$(GDALTRANSLATE)  $< $@ -of GTiff
endif


$(OUT_DIR)/%.info:$(OUT_DIR)/%.tif
	$(GDALINFO) $< > $@


$(OUT_DIR)/combined.tif:$(TIF_FILES)
	$(GDALWARP) $^ $@
	$(GDALADDO) $@ $(GDALADDO_LADDER)

$(OUT_DIR)/tiles/%:$(OUT_DIR)/%.tif
	$(GDAL2TILES) --s_srs=$(TARGET_CRS) --zoom $(GDAL_ZOOM_LEVELS) -e $< $@
#.PHONY: $(TILE_TARGETS)


tif: $(OUT_DIR)  $(TIF_FILES)

merge: $(OUT_DIR) $(OUT_DIR)/combined.tif

merge-tile: $(OUT_DIR) $(OUT_DIR)/combined.tif $(OUT_DIR)/tiles/combined

info: $(OUT_DIR) $(INFO_FILES)

s3upload: all
	$(S3CMD) put $(OUT_DIR)/* $(S3_OUT_PATH) --recursive

tile: $(TILE_TARGETS)


.PHONY:  merge info tif tile merge-tile







###################################
###  Installation Targets       ###
###################################
install:

uninstall: 


clean:
	rm -rf $(OUT_DIR)

clean_group:
	rm -rf $(OUT_ROOT)

clean_all:
	rm -rf output/*


.PHONY: install \
	uninstall \
	clean clean_group clean_all



###############################
### Debug Diagnostic Target ###
###############################
ECHO:
	@echo "TOP_DIR=$(TOP_DIR)"
	@echo "DATA_DIR=$(DATA_DIR)"
	@echo "DATA_FILES=$(DATA_FILES)"
	@echo "_DATA_FILEN=$(_DATA_FILEN)"

	@echo "OUT_DIR=$(OUT_DIR)"
	@echo "OUT_FILES=$(OUT_FILES)"
	@echo "SQL_FILES=$(SQL_FILES)"

	@echo "S3_ROOT_PATH = $(S3_ROOT_PATH)"
	@echo "S3_GROUP_PATH = $(S3_GROUP_PATH)"
	@echo "S3_OUT_PATH = $(S3_OUT_PATH)"
	@echo "TILE_TARGETS = $(TILE_TARGETS)"

.phony: ECHO
