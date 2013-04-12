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

# install phantomjs
setup:
	curl -O $(phantom_url) && unzip $(phantom_zip)
	rm -rf .phantomjs
	mv $(phantom_name) .phantomjs
	rm $(phantom_zip)

test:
	@echo '**********************************************************************'
	@echo Testing [coffee-script-jade-stylus]
	@echo '**********************************************************************'
	@cd coffee-script-jade-stylus && make test