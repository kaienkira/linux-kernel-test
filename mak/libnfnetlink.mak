LIBNFNETLINK_SRC_DIR = $(abspath src/libnfnetlink-1.0.2)

.PHONY: \
libnfnetlink-build \
libnfnetlink-clean \
libnfnetlink-compile \
libnfnetlink-install

libnfnetlink-build: libnfnetlink-compile libnfnetlink-install

libnfnetlink-clean:
	rm -rf "$(LIBNFNETLINK_SRC_DIR)"/build

libnfnetlink-compile:
	mkdir -p "$(LIBNFNETLINK_SRC_DIR)"/build
	cd "$(LIBNFNETLINK_SRC_DIR)"/build && \
		../configure \
			CFLAGS="-O2 -I$(INSTALL_DIR)/include" \
			LDFLAGS="-L$(INSTALL_DIR)/lib" \
			--prefix=/ \
			--disable-static && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

libnfnetlink-install:
	cp -r "$(LIBNFNETLINK_SRC_DIR)"/build/_install/include/* \
		"$(INSTALL_DIR)"/include/
	cp -P "$(LIBNFNETLINK_SRC_DIR)"/build/_install/lib/libnfnetlink.so* \
		"$(INSTALL_DIR)"/lib/
