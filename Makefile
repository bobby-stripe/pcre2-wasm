# ----------------------------------------------------------------------
# Compile dependencies and our bridge C code to WebAssembly,
# using emscripten.
# ----------------------------------------------------------------------

EMSCRIPTEN_VERSION=2.0.32
EMSCRIPTEN_DOCKER_RUN=docker run --rm -v $(CURDIR)/deps/build:/src:z -v $(CURDIR)/src/lib:/src/lib -u root emscripten/emsdk:$(EMSCRIPTEN_VERSION)
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
	$(CC) \
		-s WASM=1 \
		-Os \
		-g2 \
		-s EXPORTED_FUNCTIONS='["_malloc", "_free","_pcre2_pattern_info_8","_pcre2_get_ovector_pointer_8","_pcre2_get_ovector_count_8","_pcre2_config_8","_pcre2_substitute_8","_pcre2_match_data_free_8","_pcre2_match_8","_pcre2_compile_8","_pcre2_get_error_message_8","_pcre2_pattern_info_8","_pcre2_substring_number_from_name_8","_pcre2_match_data_create_from_pattern_8","_pcre2_code_free_8"]' \
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
