CS=node_modules/coffee-script/bin/coffee
VERSION=`$(CS) build/bumper.coffee --version`


# called only by NPM
prepublish: setup.tests
	make build CS=coffee



setup: setup.tests
	npm link

setup.tests:
	@cd tests && make setup

test:
	@cd tests && make test



watch:
	$(CS) -wmco lib src

build:
	$(CS) -mco lib src



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



.PHONY: build