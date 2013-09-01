CS=node_modules/coffee-script/bin/coffee

MVERSION=node_modules/.bin/mversion
VERSION=`$(MVERSION) | sed -E 's/\* package.json: //g'`

ISTANBUL=node_modules/istanbul/lib/cli.js
MOCHA=node_modules/mocha/bin/mocha
_MOCHA=node_modules/mocha/bin/_mocha
COVERALLS=node_modules/coveralls/bin/coveralls.js


POLVO=bin/polvo



setup:
	npm link



watch:
	$(CS) -bwmco lib src

build:
	$(CS) -bmco lib src



test:
	@$(MOCHA) --compilers coffee:coffee-script \
		--ui bdd \
		--reporter spec \
		--recursive \
		--timeout 5000 \
		tests/unit

test.coverage:
	@$(ISTANBUL) cover $(_MOCHA) -- \
		--compilers coffee:coffee-script \
		--ui bdd \
		--reporter spec \
		--recursive \
		--timeout 5000 \
		tests/unit

test.coverage.preview: test.coverage
	@cd coverage/lcov-report && python -m SimpleHTTPServer 8080

test.coverage.coveralls: test.coverage
	@sed -i.bak \
		"s/^.*polvo\/lib/SF:lib/g" \
		coverage/lcov.info

	@cat coverage/lcov.info | $(COVERALLS)



bump.minor:
	@$(MVERSION) minor

bump.major:
	@$(MVERSION) major

bump.patch:
	@$(MVERSION) patch



publish:
	git tag $(VERSION)
	git push origin $(VERSION)
	git push origin master
	npm publish

re-publish:
	git tag -d $(VERSION)
	git tag $(VERSION)
	git push origin :$(VERSION)
	git push origin $(VERSION)
	git push origin master -f
	npm publish -f



.PHONY: build