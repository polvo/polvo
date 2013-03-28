.PHONY: build

CS=node_modules/coffee-script/bin/coffee
VOWS=node_modules/vows/bin/vows
VERSION=`$(CS) build/bumper.coffee --version`

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

setup:
	sudo npm link

test: build
	$(VOWS) spec/*.coffee --spec



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