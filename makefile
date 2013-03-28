.PHONY: build

CS=node_modules/coffee-script/bin/coffee
MOCHA=node_modules/mocha/bin/mocha
VERSION=`$(CS) build/bumper.coffee --version`

setup:
	sudo npm link

compile.loader:
	$(CS) -o lib/loader -j toaster.coffee -cb \
		src/loader/script.coffee \
		src/loader/chunk.coffee \
		src/loader/toaster.coffee

watch.loader:
	$(CS) -o lib/loader -j toaster.coffee -cbw \
		src/loader/script.coffee \
		src/loader/chunk.coffee \
		src/loader/toaster.coffee


test.clean:
	# rm -rf tests/tmp-*

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