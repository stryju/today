#SRC = $(wildcard lib/**/*.js)
#MINIFY = $(BINS)/uglifyjs
#PID = test/server/pid.txt
BINS = node_modules/.bin
CLEANCSS = $(BINS)/cleancss
#BUILD = build.js
#DUO = $(BINS)/duo --stdout --use duo-babel
#DUOT = $(BINS)/duo-test -p test/server -R spec -P $(PORT) -c "make build.js"

build/index.html: src/index.tpl
	sed -i -e "/@__STYLE__@/{ r $< }d" $@
	# sed -i.bak s/STRING_TO_REPLACE/STRING_TO_REPLACE_IT/g index.html

build/style.css: src/style.css
	$(CLEANCSS) -o $@ $<
