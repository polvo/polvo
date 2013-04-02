.PHONY: build

CS=node_modules/coffee-script/bin/coffee
MOCHA=node_modules/mocha/bin/mocha
VERSION=`$(CS) build/bumper.coffee --version`



setup:
	npm link

watch:
	$(CS) -wmco lib src

compile:
	$(CS) -mco lib src



test: test.clean
	$(MOCHA) tests/* \
		--compilers coffee:coffee-script \
		--require should --reporter spec


bump.minor:
	$(CS) build/bumper.coffee --minor

bump.major:
	$(CS) build/bumper.coffee --major

bump.patch:
	$(CS) build/bumper.coffee --patch



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