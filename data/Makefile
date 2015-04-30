include config.mk

.PHONY : all
all: house senate

.PHONY: clean
clean: 
	rm merged_eitc_senate.geojson merged_eitc_house.geojson 


.PHONY : house
house: merged_eitc_house.geojson 

.PHONEY : senate
senate: merged_eitc_senate.geojson 

.PHONEY : cleanup_shapefiles
cleanup_shapefiles :		
	rm *.dbf *.prj *.sbn *.shx *.xml *.sbx

.INTERMEDIATE : senate_boundaries.shp house_boundaries.shp
house_boundaries.shp senate_boundaries.shp : House\ and\ Senate\ shape\ files.zip
	unzip -j "$<"
	rename -v 's/PA 97-6 Senate Districts(.*)/senate_boundaries$$1/' *.*
	rename -v 's/PA 97-6 House Districts(.*)/house_boundaries$$1/' *.*
	touch house_boundaries.shp
	touch senate_boundaries.shp

%.table: %.shp
	shp2pgsql -I -s 4326 -d $< $* | \
		psql -d $(PG_DB) -U $(PG_USER) -h $(PG_HOST) -p $(PG_PORT)
	touch $@

.INTERMEDIATE : eitc_senate.csv
eitc_senate.csv: IL\ EITC\ Data\ by\ State\ Senate\ Legislative\ District.csv
	cp "$<" $@

.INTERMEDIATE : eitc_house.csv
eitc_house.csv: IL\ EITC\ Data\ by\ State\ House\ Legislative\ District\ v5.csv
	cp "$<" $@


eitc_%.table: eitc_%.csv
	psql -d $(PG_DB) -U $(PG_USER) -h $(PG_HOST) -p $(PG_PORT) -c "DROP TABLE IF EXISTS info_by_$*"
	csvsql $< \
		--db "postgresql://$(PG_USER):@$(PG_HOST):$(PG_PORT)/$(PG_DB)" --table info_by_$* --insert
	touch $@


merged_eitc_%.shp: %_boundaries.table eitc_%.table
	pgsql2shp -f $@ -h $(PG_HOST) -u $(PG_USER) -p $(PG_PORT) $(PG_DB) \
		"SELECT $*_boundaries.geom, info_by_$*.* FROM $*_boundaries \
		JOIN info_by_$* ON $*_boundaries.district_1 = cast(info_by_$*.il$*dist as smallint)"

merged_eitc_%.geojson: merged_eitc_%.shp
	ogr2ogr -simplify 0.0001 -f GeoJSON $@ $<






.PHONY : create_db
create_db :
	createdb eitc
	psql -d eitc -c "CREATE EXTENSION postgis"
