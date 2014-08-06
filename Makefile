CS=node_modules/coffee-script/bin/coffee

MVERSION=node_modules/mversion/bin/version
VERSION=`$(MVERSION) | sed -E 's/\* package.json: //g'`

ISTANBUL=node_modules/istanbul/lib/cli.js
MOCHA=node_modules/mocha/bin/mocha
_MOCHA=node_modules/mocha/bin/_mocha
COVERALLS=node_modules/coveralls/bin/coveralls.js


POLVO=bin/polvo
BOWER=node_modules/.bin/bower
COMPONENT=node_modules/.bin/component


setup:
	@npm link
	@make test.install.dependencies



watch:
	@$(CS) -bwmco lib src

build:
	@$(CS) -bmco lib src

test.clean:
	@git clean -fdx tests/fixtures
	@make test.install.dependencies

test.install.dependencies:
	@cd tests/fixtures/package-systems && npm install
	@cd tests/fixtures/package-systems && ../../../$(BOWER) install
	@cd tests/fixtures/package-systems && ../../../$(COMPONENT) install


test: build 
	@$(MOCHA) --compilers coffee:coffee-script \
		--ui bdd \
		--reporter spec \
		--recursive \
		--timeout 10000 \
		tests/tests

test.coverage: build
	@$(ISTANBUL) cover $(_MOCHA) -- \
		--compilers coffee:coffee-script \
		--ui bdd \
		--reporter spec \
		--recursive \
		--timeout 10000 \
		tests/tests

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