.PHONY: build

CS=node_modules/coffee-script/bin/coffee
VOWS=node_modules/vows/bin/vows
VERSION=`$(CS) build/bumper --version`


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