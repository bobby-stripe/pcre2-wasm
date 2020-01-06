# ----------------------------------------------------------------------
# Compile dependencies and our bridge C code to WebAssembly,
# using emscripten.
# ----------------------------------------------------------------------

EMSCRIPTEN_DOCKER_RUN=docker run --rm -v $(CURDIR)/deps/build:/src -v $(CURDIR)/src/lib:/src/lib -u emscripten trzeci/emscripten:sdk-tag-1.39.4-64bit
CC=$(EMSCRIPTEN_DOCKER_RUN) emcc

export

# ----------------------------------------------------------------------

.PHONY: all deps

all: dist/libpcre2.js

dist:
	mkdir -p dist

deps:
	$(MAKE) -C deps

# ----------------------------------------------------------------------

dist/libpcre2.js: src/lib/libpcre2.c src/lib/config.js | deps dist
	$(CC) /src/lib/libpcre2.c \
		-g \
		-s WASM=1 \
		-O3 \
		--pre-js /src/lib/config.js \
		-s EXPORTED_FUNCTIONS='["_malloc", "_free"]' \
		-s EXTRA_EXPORTED_RUNTIME_METHODS='["cwrap", "ccall", "getValue"]' \
		-I/src/local/include \
		-L/src/local/lib \
		-lpcre2-16 \
		-o libpcre2.js
	cp deps/build/libpcre2.* dist/

# ----------------------------------------------------------------------
