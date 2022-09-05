GRUB_SRC_DIR = $(abspath src/grub-2.06)

.PHONY: grub-build grub-clean

grub-build:
	mkdir -p $(GRUB_SRC_DIR)/build
	cd $(GRUB_SRC_DIR)/build && \
		../configure \
			LDFLAGS="--static" \
			--disable-werror \
			--prefix=/opt/grub \
			--with-platform="pc" \
			--target="i386" && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

grub-clean:
	rm -rf $(GRUB_SRC_DIR)/build
