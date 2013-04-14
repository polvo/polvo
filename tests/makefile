# CONFIGS ----------------------------------------------------------------------

# phantom paths
phantom_name=phantomjs-1.9.0-macosx
phantom_zip=$(phantom_name).zip
phantom_url=https://phantomjs.googlecode.com/files/$(phantom_zip)

# mocha paths
mocha_phantom=node_modules/mocha-phantomjs/lib/mocha-phantomjs.coffee

# polvo path
polvo=../bin/polvo



# TARGETS ----------------------------------------------------------------------

# install phantomjs locally (but only if it's yet installed)
setup:
	@if ! [ -d .phantomjs ]; \
	then \
		curl -O $(phantom_url) && unzip $(phantom_zip); \
		mv $(phantom_name) .phantomjs && rm $(phantom_zip); \
	fi

test:
	@echo '**********************************************************************'
	@echo Testing [coffeescript-jade-stylus]
	@echo '**********************************************************************'
	@cd coffeescript-jade-stylus && make test