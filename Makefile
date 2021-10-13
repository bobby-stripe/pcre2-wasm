# ----------------------------------------------------------------------
# Compile dependencies and our bridge C code to WebAssembly,
# using emscripten.
# ----------------------------------------------------------------------

EMSCRIPTEN_DOCKER_RUN=docker run --rm -v $(CURDIR)/deps/build:/src:z -v $(CURDIR)/src/lib:/src/lib -u root emscripten/emsdk:2.0.31
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
		-s WASM=1 \
		-Os \
		-g2 \
		-s EXPORTED_FUNCTIONS='["_malloc", "_free"]' \
		-s EXPORTED_RUNTIME_METHODS='["cwrap", "ccall", "getValue"]' \
		-s BINARYEN=1 \
		-s FILESYSTEM=0 \
		-s DYNAMIC_EXECUTION=0 \
		-s ALLOW_MEMORY_GROWTH=1 \
		-s STANDALONE_WASM \
		--no-entry \
		-I/src/local/include \
		-L/src/local/lib \
		-lpcre2-8 \
		-o libpcre2.wasm
	cp deps/build/libpcre2.wasm dist/

# ----------------------------------------------------------------------
