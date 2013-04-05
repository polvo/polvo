# CONFIGS ----------------------------------------------------------------------

# mocha paths
mocha_phantom=../../node_modules/mocha-phantomjs/lib/mocha-phantomjs.coffee

# phantom paths
# tries to detect a working versin of phantomjs (in TravisCLI for example)
ifdef `phantomjs`
	phantom=phantomjs
# and if it's not present, uses the embed phantom
else
	phantom=../.phantomjs/bin/phantomjs
endif

# polvo path
polvo=../../bin/polvo



# TARGETS ----------------------------------------------------------------------

# starts watching'compiling project, serving it locally at http://localhost:3000
dev:
	@$(polvo) -ws

# optimize project for release
release:
	@$(polvo) -r

# optimize project for release and serves it locally at http://localhost:3000
release.preview:
	@$(polvo) -rs



# run mocha tests via mocha-phantom using phantomjs
test: test.dev test.release

# test dev version
test.dev:
	@echo ''
	@echo '∆ testing `development` version'
	@echo ''
	@$(polvo) -c
	@echo ''
	@$(phantom) $(mocha_phantom) www/index.html

# testing release version
test.release:
	@echo ''
	@echo '∆ testing `release` version'
	@echo ''
	@$(polvo) -r
	@echo ''
	@$(phantom) $(mocha_phantom) www/index.html