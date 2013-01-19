.PHONY: build

VERSION=`node_modules/coffee-script/bin/coffee build/bumper --version`

setup:
	sudo npm link

test: build
	node_modules/vows/bin/vows spec/*.coffee --spec



bump.minor:
	coffee build/bumper.coffee --minor

bump.major:
	coffee build/bumper.coffee --major

bump.patch:
	coffee build/bumper.coffee --patch



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