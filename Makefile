BRANCH = gh-pages
BINS = node_modules/.bin
CLEANCSS = $(BINS)/cleancss
HTMLMINIFIER = $(BINS)/html-minifier \
	--remove-optional-tags \
	--remove-empty-attributes \
	--remove-redundant-attributes \
	--collapse-boolean-attributes \
	--remove-attribute-quotes \
	--remove-comments \
	--collapse-whitespace

publish: build/index.html
	@echo publishing
	@git config user.name "Travis-CI" && \
		git config user.email "travis@stryju.pl"
	@git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
	@git fetch
	@git checkout -t origin/$(BRANCH)
	@cp $< .
	[ -z "$(git status -uno --porcelain)" ] || \
		( \
			git add index.html && \
			git commit -m "$$(date '+%Y-%m-%d')" && \
			( git push "https://${GH_TOKEN}@$github.com/stryju/today.git" master:$(BRANCH) > /dev/null 2>&1 ) \
		)

build/index.html: tmp/head.html tmp/body.html
	@echo building index.html
	@mkdir -p build
	@cat $^ | $(HTMLMINIFIER) > $@

tmp/head.html: tpl/_head.tpl tmp/style.css
	@echo building head
	@mkdir -p tmp
	@sed "s/@__CSS__@/$$(sed -e 's/[\&/]/\\&/g' tmp/style.css)/" $< > $@

tmp/style.css: tpl/style.css node_modules
	@echo building styles
	@mkdir -p tmp
	@$(CLEANCSS) < $< > $@

mdfiles   := $(shell ls data | sort -r )
datafiles := $(patsubst %.md,tmp/%.html,$(mdfiles))

tmp/body.html: tpl/_body.tpl $(datafiles)
	@echo building body
	@cat $^ | sed '1,/<details>/s/<details>/<details open>/' > $@

tmp/%.html: data/%.md tpl/_article.tpl node_modules
	@mkdir -p tmp
	@sed -e "s/@__ID__@/$*/g" \
		-e "s/@__DAY__@/$$(node scripts/day.js $*)/"\
		-e "s/@__CONTENT__@/$$(node scripts/md.js $<)/"\
		tpl/_article.tpl > $@

clean:
	@rm -rf ./tmp
	@rm -rf ./build

node_modules: package.json
	@npm install
