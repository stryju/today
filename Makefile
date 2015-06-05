BINS = node_modules/.bin
CLEANCSS = $(BINS)/cleancss

publish: build/index.html
	@ echo publishing
	@ git co gh-pages && git pull
	@ cp $< .
	@ echo git add index.html && \
	git commit -m "$$(date '+%Y-%m-%d')" \
	git push && \
	git co master

build/index.html: tmp/head.html tmp/body.html
	@ echo building index.html
	@ mkdir -p build
	@ cat $^ > $@

tmp/head.html: tpl/_head.tpl tmp/style.css
	@ echo building head
	@ mkdir -p tmp
	@ sed "s/@__CSS__@/$$(sed -e 's/[\&/]/\\&/g' tmp/style.css)/" $< > $@

tmp/style.css: tpl/style.css
	@ echo building styles
	@ mkdir -p tmp
	@ $(CLEANCSS) < $< > $@

mdfiles   := $(shell ls data | sort -r )
datafiles := $(patsubst %.md,tmp/%.html,$(mdfiles))

tmp/body.html: tpl/_body.tpl $(datafiles)
	@ echo building body
	@ cat $^ > $@

tmp/%.html: data/%.md tpl/_article.tpl
	@ mkdir -p tmp
	@ sed -e "s/@__ID__@/$*/g" \
		-e "s/@__DAY__@/$$(node scripts/day.js $*)/"\
		-e "s/@__CONTENT__@/$$(node scripts/md.js $<)/"\
		tpl/_article.tpl > $@

clean:
	@ rm -rf ./tmp
	@ rm -rf ./build

.PHONY: data
