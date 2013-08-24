CS=node_modules/coffee-script/bin/coffee

MVERSION=node_modules/.bin/mversion
VERSION=`$(MVERSION) | sed -E 's/\* package.json: //g'`

ISTANBUL=node_modules/istanbul/lib/cli.js
MOCHA=node_modules/mocha/bin/mocha
_MOCHA=node_modules/mocha/bin/_mocha


POLVO=bin/polvo

setup:
	npm link
	@cd tests && make setup



watch:
	$(CS) -wmco lib src

build:
	$(CS) -mco lib src



test:
	@$(MOCHA) --compilers coffee:coffee-script \
		--ui bdd \
		--reporter spec \
		tests/functional

test.coverage:
	@$(ISTANBUL) cover $(_MOCHA) -- \
	--compilers coffee:coffee-script \
	--ui bdd \
	--reporter spec \
	tests/functional


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