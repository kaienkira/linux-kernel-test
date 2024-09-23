LIBXCRYPT_SRC_DIR = $(abspath src/libxcrypt-4.4.36)

.PHONY: \
libxcrypt-build \
libxcrypt-clean \
libxcrypt-compile \
libxcrypt-install

libxcrypt-build: libxcrypt-compile libxcrypt-install

libxcrypt-clean:
	rm -rf $(LIBXCRYPT_SRC_DIR)/build

libxcrypt-compile:
	mkdir -p $(LIBXCRYPT_SRC_DIR)/build
	cd $(LIBXCRYPT_SRC_DIR)/build && \
		../configure \
			CFLAGS="-O2" \
			--prefix=/ \
			--disable-static && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

libxcrypt-install:
	cp -r $(LIBXCRYPT_SRC_DIR)/build/_install/include/* \
		$(INSTALL_DIR)/include/
	cp -P $(LIBXCRYPT_SRC_DIR)/build/_install/lib/libcrypt.so* \
		$(INSTALL_DIR)/lib/
