GLIBC_SRC_DIR = $(abspath src/glibc-2.42)

.PHONY: \
glibc-build \
glibc-clean \
glibc-compile \
glibc-install

glibc-build: glibc-compile glibc-install

glibc-clean:
	rm -rf $(GLIBC_SRC_DIR)/build

glibc-compile:
	mkdir -p $(GLIBC_SRC_DIR)/build
	cd $(GLIBC_SRC_DIR)/build && \
		../configure \
		    CFLAGS='-O2' \
			--prefix=/usr \
			--with-headers=$(INSTALL_DIR)/include \
			--enable-kernel=6.12 \
			--disable-profile \
			--disable-timezone-tools \
			--disable-build-nscd \
			--disable-nscd \
			--without-gd \
			--without-selinux && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=$(GLIBC_SRC_DIR)/build/_install install

glibc-install:
	cp -r $(GLIBC_SRC_DIR)/build/_install/usr/include/* \
		$(INSTALL_DIR)/include/
	cp -P $(GLIBC_SRC_DIR)/build/_install/lib64/ld-linux-x86-64.so.2 \
		$(INSTALL_DIR)/lib/
	cp -P $(GLIBC_SRC_DIR)/build/_install/lib64/libc.so.6 \
		$(INSTALL_DIR)/lib/
	cp -P $(GLIBC_SRC_DIR)/build/_install/lib64/libm.so.6 \
		$(INSTALL_DIR)/lib/
	cp -P $(GLIBC_SRC_DIR)/build/_install/lib64/libresolv.so.2 \
		$(INSTALL_DIR)/lib/
	cd $(INSTALL_DIR)/lib && \
		ln -sf libc.so.6 libc.so && \
		ln -sf libm.so.6 libm.so && \
		ln -sf libresolv.so.2 libresolv.so
