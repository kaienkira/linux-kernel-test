LIBMNL_SRC_DIR = $(abspath src/libmnl-1.0.5)

.PHONY: \
libmnl-build \
libmnl-clean \
libmnl-compile \
libmnl-install

libmnl-build: libmnl-compile libmnl-install

libmnl-clean:
	rm -rf "$(LIBMNL_SRC_DIR)"/build

libmnl-compile:
	mkdir -p "$(LIBMNL_SRC_DIR)"/build
	cd "$(LIBMNL_SRC_DIR)"/build && \
		../configure \
			CFLAGS="-O2" \
			--prefix=/ \
			--disable-static && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

libmnl-install:
	cp -r "$(LIBMNL_SRC_DIR)"/build/_install/include/* \
		"$(INSTALL_DIR)"/include/
	cp -P "$(LIBMNL_SRC_DIR)"/build/_install/lib/libmnl.so* \
		"$(INSTALL_DIR)"/lib/
