all: clean data pdf site

clean:
	@rm -rf _book
	@rm -rf _bookdown_files

clean_temp:
	@rm -f prioritizr-workshop-manual.Rmd
	@rm -f prioritizr-workshop-manual-teaching.Rmd

data:
	mkdir -p data
	Rscript -e "library(prioritizrdata);library(raster);data(tas_pu,tas_features);tas_pu[['locked_out']]<-as.numeric((tas_pu[['cost']] > quantile(tas_pu[['cost']], 0.85)[[1]]) & !tas_pu[['locked_in']]); rgdal::writeOGR(tas_pu,'data','pu',overwrite=TRUE,driver='ESRI Shapefile');writeRaster(tas_features,'data/vegetation.tif',overwrite=TRUE,NAflag=-9999)"
	zip -r data.zip data
	rm -rf data

site: clean_temp
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"

pdf: clean_temp
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"
	rm -f prioritizr-workshop-manual.log

check:
	R -e "source('verify-solutions.R')"
	rm -f Rplots.pdf

.PHONY: data clean check website site data
