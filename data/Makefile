VPATH = raw:finished_files:build
include config.mk

GENERATED_FILES_HOUSE = house_boundaries.shp \
eitc_house.csv \
eitc_house.table \
house_boundaries.table \
merged_eitc_house.shp \
merged_eitc_house.geojson

GENERATED_FILES_SENATE = senate_boundaries.shp \
eitc_senate.csv \
eitc_senate.table \
senate_boundaries.table \
merged_eitc_senate.shp \
merged_eitc_senate.geojson

.PHONY: all clean full_clean

clean:
	rm -Rf build/*

full_clean: 
	echo 'full_clean'
	rm -Rf build/*
	rm -Rf finished_files/*

all: 
	$(GENERATED_FILES_HOUSE)
	$(GENERATED_FILES_SENATE)

house: $(GENERATED_FILES_HOUSE)

senate: $(GENERATED_FILES_SENATE)

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

merged_eitc_house.shp: house_boundaries.table eitc_house.table
	echo 'merged_eitc_house.shp'
	pgsql2shp -f finished_files/$@ -h $(PG_HOST) -u $(PG_USER) -p $(PG_PORT) $(PG_DB) \
		"SELECT house_boundaries.geom, info_by_dist.* FROM house_boundaries \
		JOIN info_by_dist ON house_boundaries.district_1 = cast(info_by_dist.ilhousedist as smallint)"

merged_eitc_house.geojson: merged_eitc_house.shp
	echo 'merged_eitc_house.geojson'
	@ogr2ogr -simplify 0.0001 -f GeoJSON finished_files/$@ finished_files/$(notdir $?); \


senate_boundaries.shp:
	echo 'senate_boundaries.shp'
	unzip raw/House\ and\ Senate\ shape\ files.zip -d raw/
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.dbf raw/senate_boundaries.dbf
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.prj raw/senate_boundaries.prj
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.sbn raw/senate_boundaries.sbn
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.sbx raw/senate_boundaries.sbx
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.shp raw/senate_boundaries.shp
	mv raw/House\ and\ Senate\ shape\ files/PA\ 97-6\ Senate\ Districts.shx raw/senate_boundaries.shx
	
senate_boundaries.table: senate_boundaries.shp
	echo 'senate_boundaries.table'
	shp2pgsql -I -s 4326 -d raw/$(notdir $?) senate_boundaries | \
		psql -d $(PG_DB) -U $(PG_USER) -h $(PG_HOST) -p $(PG_PORT)
	@touch build/$@

eitc_senate.csv:
	echo 'eitc_senate.csv'
	cp raw/"IL EITC Data by State Senate Legislative District.csv" build/$@

eitc_senate.table: eitc_senate.csv
	echo 'eitc_senate.table'
	psql -d $(PG_DB) -U $(PG_USER) -h $(PG_HOST) -p $(PG_PORT) -c "DROP TABLE IF EXISTS info_by_senate"
	csvsql build/$(notdir $?) \
		--db "postgresql://$(PG_USER):@$(PG_HOST):$(PG_PORT)/$(PG_DB)" --table info_by_senate --insert
	@touch build/$@

merged_eitc_senate.shp: senate_boundaries.table eitc_senate.table
	echo 'merged_eitc_senate.shp'
	pgsql2shp -f finished_files/$@ -h $(PG_HOST) -u $(PG_USER) -p $(PG_PORT) $(PG_DB) \
		"SELECT senate_boundaries.geom, info_by_senate.* FROM senate_boundaries \
		JOIN info_by_senate ON senate_boundaries.district_1 = cast(info_by_senate.ilsenatedist as smallint)"

merged_eitc_senate.geojson: merged_eitc_senate.shp
	echo 'merged_eitc_senate.geojson'
	@ogr2ogr -simplify 0.0001 -f GeoJSON finished_files/$@ finished_files/$(notdir $?); \
