VPATH = raw:finished_files:build
include config.mk

GENERATED_FILES = house_boundaries.shp \
eitc_house.csv \
eitc_house.table \
house_boundaries.table \
merged_eitc_house.shp \
merged_eitc_house.geojson

.PHONY: all clean full_clean

clean:
	rm -Rf build/*

full_clean: 
	echo 'full_clean'
	rm -Rf build/*
	rm -Rf finished_files/*

all: $(GENERATED_FILES)

house_boundaries.shp:
	echo 'house_boundaries.shp'
	unzip raw/House\ and\ Senate\ shape\ files.zip -d raw/
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ House\ Districts.dbf raw/house_boundaries.dbf
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ House\ Districts.prj raw/house_boundaries.prj
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ House\ Districts.sbn raw/house_boundaries.sbn
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ House\ Districts.sbx raw/house_boundaries.sbx
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ House\ Districts.shp raw/house_boundaries.shp
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ House\ Districts.shx raw/house_boundaries.shx
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ House\ Districts.xml raw/house_boundaries.xml

senate_boundaries.shp:
	echo 'senate_boundaries.shp'
	unzip raw/House\ and\ Senate\ shape\ files.zip -d raw/
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.dbf raw/house_boundaries.dbf
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.prj raw/house_boundaries.prj
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.sbn raw/house_boundaries.sbn
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.sbx raw/house_boundaries.sbx
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.shp raw/house_boundaries.shp
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.shx raw/house_boundaries.shx
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.xml raw/house_boundaries.xml

eitc_house.csv:
	echo 'eitc_house.csv'
	cp raw/"IL EITC Data by State House Legislative District v5.csv" build/$@

eitc_house.table: eitc_house.csv
	echo 'eitc_house.table'
	psql -d $(PG_DB) -U $(PG_USER) -h $(PG_HOST) -p $(PG_PORT) -c "DROP TABLE IF EXISTS info_by_dist"
	csvsql build/$(notdir $?) \
		--db "postgresql://$(PG_USER):@$(PG_HOST):$(PG_PORT)/$(PG_DB)" --table info_by_dist --insert
	@touch build/$@

house_boundaries.table: house_boundaries.shp
	echo 'house_boundaries.table'
	shp2pgsql -I -s 4326 -d raw/$(notdir $?) house_boundaries | \
		psql -d $(PG_DB) -U $(PG_USER) -h $(PG_HOST) -p $(PG_PORT)
	@touch build/$@

senate_boundaries.table: senate_boundaries.shp
	echo 'senate_boundaries.table'
	shp2pgsql -I -s 4326 -d raw/$(notdir $?) senate_boundaries | \
		psql -d $(PG_DB) -U $(PG_USER) -h $(PG_HOST) -p $(PG_PORT)
	@touch build/$@

merged_eitc_house.shp: house_boundaries.table eitc_house.table
	echo 'merged_eitc_house.shp'
	pgsql2shp -f finished_files/$@ -h $(PG_HOST) -u $(PG_USER) -p $(PG_PORT) $(PG_DB) \
		"SELECT house_boundaries.geom, info_by_dist.* FROM house_boundaries \
		JOIN info_by_dist ON house_boundaries.district_1 = cast(info_by_dist.ilhousedist as smallint)"

merged_eitc_house.geojson: merged_eitc_house.shp
	echo 'merged_eitc_house.geojson'
	@ogr2ogr -simplify 0.0001 -f GeoJSON finished_files/$@ finished_files/$(notdir $?); \
