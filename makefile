CS=node_modules/coffee-script/bin/coffee
VERSION=`$(CS) build/bumper.coffee --version`


install: setup compile



setup:
	@cd tests && make setup

setup.dev:
	npm link



watch:
	$(CS) -wmco lib src

compile:
	$(CS) -mco lib src



test:
	@cd tests && make test



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