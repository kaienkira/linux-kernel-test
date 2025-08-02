LIBNETFILTER_CONNTRACK_SRC_DIR = $(abspath src/libnetfilter_conntrack-1.0.9)

.PHONY: \
libnetfilter_conntrack-build \
libnetfilter_conntrack-clean \
libnetfilter_conntrack-compile \
libnetfilter_conntrack-install

libnetfilter_conntrack-build: \
libnetfilter_conntrack-compile \
libnetfilter_conntrack-install

libnetfilter_conntrack-clean:
	rm -rf "$(LIBNETFILTER_CONNTRACK_SRC_DIR)"/build

libnetfilter_conntrack-compile:
	mkdir -p "$(LIBNETFILTER_CONNTRACK_SRC_DIR)"/build
	cd "$(LIBNETFILTER_CONNTRACK_SRC_DIR)"/build && \
		../configure \
			CFLAGS="-O2 -I$(INSTALL_DIR)/include" \
			LDFLAGS="-L$(INSTALL_DIR)/lib" \
			--prefix=/ \
			--disable-static && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

libnetfilter_conntrack-install:
	cp -r "$(LIBNETFILTER_CONNTRACK_SRC_DIR)"/build/_install/include/* \
		"$(INSTALL_DIR)"/include/
	cp -P "$(LIBNETFILTER_CONNTRACK_SRC_DIR)"/build/_install/lib/libnetfilter_conntrack.so* \
		"$(INSTALL_DIR)"/lib/
