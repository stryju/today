BRANCH = gh-pages
GH_REPO = github.com/stryju/today.git
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

mdsrc     := $(shell find data -iname "*.md" | sed '1!G;h;$!d' | sed 's!.*/!!')
mdfiles   := $(mdsrc:%.md=tmp/%.md)
datafiles := $(mdsrc:%.md=tmp/%.html)

README.md: tpl/README.header.md $(mdfiles) tpl/README.footer.md
	@echo publishing
	@cat $^ > README.md
	@git pull
	@git add data $@ && \
		git commit -m "$$(date '+%Y-%m-%d')" && \
		git push

travis: build/index.html
	@echo publishing
	@git config user.name "Travis-CI" && \
		git config user.email "travis@stryju.pl"
	@git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
	@git fetch
	@git checkout -t origin/$(BRANCH) && git pull
	@cp $< .
	@git add index.html
	@git status -uno --porcelain
	@git diff-index --quiet HEAD  || \
		( \
			git commit -m "$$(date '+%Y-%m-%d')" && \
			git push "https://${GH_TOKEN}@${GH_REPO}" $(BRANCH):$(BRANCH) > /dev/null 2>&1 && \
			echo && \
			echo "$$(date '+%Y-%m-%d') published" \
		)

build/index.html: tmp/head.html tmp/body.html tmp/footer.html
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

tmp/body.html: tpl/_body.tpl $(datafiles)
	@echo building body
	@cat $^ | sed '1,/<details>/s/<details>/<details open>/' > $@

tmp/footer.html: tpl/_footer.tpl
	@echo building footer
	@cat $< > $@

tmp/%.html: data/*/%.md tpl/_article.tpl node_modules
	@mkdir -p tmp
	@sed -e "s/@__ID__@/$*/g" \
		-e "s/@__DAY__@/$$(node scripts/day.js $*)/"\
		-e "s/@__CONTENT__@/$$(node scripts/md.js $<)/"\
		tpl/_article.tpl > $@

tmp/%.md: data/*/%.md
	@mkdir -p tmp
	@echo "## $*\n\n$$(cat $<)\n\n" > $@

clean:
	@rm -rf ./tmp
	@rm -rf ./build
	@rm ./README.md

node_modules: package.json
	@npm install
