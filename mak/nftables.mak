NFTABLES_SRC_DIR = $(abspath src/nftables-1.1.6)

.PHONY: \
nftables-build \
nftables-clean \
nftables-compile \
nftables-install

nftables-build: nftables-compile nftables-install

nftables-clean:
	rm -rf "$(NFTABLES_SRC_DIR)"/build

nftables-compile:
	mkdir -p "$(NFTABLES_SRC_DIR)"/build
	cd "$(NFTABLES_SRC_DIR)"/build && \
		../configure \
			CFLAGS="-O2 -I$(INSTALL_DIR)/include" \
			LDFLAGS="-L$(INSTALL_DIR)/lib" \
			--prefix=/ \
			--with-mini-gmp \
			--without-cli \
			--disable-static && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

nftables-install:
	cp -r "$(NFTABLES_SRC_DIR)"/build/_install/include/* \
		"$(INSTALL_DIR)"/include/
	cp -P "$(NFTABLES_SRC_DIR)"/build/_install/lib/libnftables.so* \
		"$(INSTALL_DIR)"/lib/
	cp -P "$(NFTABLES_SRC_DIR)"/build/_install/sbin/nft \
		"$(INSTALL_DIR)"/sbin/
