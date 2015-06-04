#SRC = $(wildcard lib/**/*.js)
#MINIFY = $(BINS)/uglifyjs
#PID = test/server/pid.txt
BINS = node_modules/.bin
CLEANCSS = $(BINS)/cleancss
#BUILD = build.js
#DUO = $(BINS)/duo --stdout --use duo-babel
#DUOT = $(BINS)/duo-test -p test/server -R spec -P $(PORT) -c "make build.js"

build/index.html: src/index.tpl
	@ mkdir -p build
	@ sed -e '/@__STYLE__@/{ r build/style.css' -e '}' $< > $@

build/style.css: src/style.css
	@ $(CLEANCSS) -o $@ $<
