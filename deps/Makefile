# ----------------------------------------------------------------------
# Download and build PCRE2 library
# ----------------------------------------------------------------------

PCRE2_VERSION=10.38
PCRE2_TARBALL_URL=https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$(PCRE2_VERSION)/pcre2-$(PCRE2_VERSION).tar.gz

# ----------------------------------------------------------------------

.PHONY: all

all: build/local/include/pcre2.h build/local/lib/libpcre2-8.a

# ----------------------------------------------------------------------

build:
	mkdir -p build/local

# ----------------------------------------------------------------------

build/pcre2-$(PCRE2_VERSION).tar.gz: | build
	curl -L -o build/pcre2-$(PCRE2_VERSION).tar.gz $(PCRE2_TARBALL_URL)

build/pcre2-$(PCRE2_VERSION): build/pcre2-$(PCRE2_VERSION).tar.gz
	tar -xzf build/pcre2-$(PCRE2_VERSION).tar.gz -C build
	touch build/pcre2-$(PCRE2_VERSION)

build/local/include/pcre2.h build/local/lib/libpcre2-8.a: build/pcre2-$(PCRE2_VERSION)
	$(EMSCRIPTEN_DOCKER_RUN) sh -c " \
	  cd pcre2-$(PCRE2_VERSION) \
		&& emconfigure ./configure --prefix=/src/local \
		                           --enable-pcre2-8 \
								   --disable-jit \
								   --with-heap-limit=2000000 \
  --disable-pcre2grep-jit \
  --disable-pcre2grep-callout \
  --disable-pcre2grep-callout-fork \
		&& emmake make \
		&& emmake make install \
	"

# ----------------------------------------------------------------------
