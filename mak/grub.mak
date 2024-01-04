GRUB_SRC_DIR = $(abspath src/grub-2.12)

.PHONY: grub-build grub-clean

grub-build:
	# build hack
	echo "depends bli part_gpt" > $(GRUB_SRC_DIR)/grub-core/extra_deps.lst
	mkdir -p $(GRUB_SRC_DIR)/build
	cd $(GRUB_SRC_DIR)/build && \
		../configure \
			LDFLAGS="--static" \
			--disable-werror \
			--prefix=/opt/grub \
			--with-platform="pc" \
			--enable-device-mapper=no \
			--enable-grub-emu-sdl=no \
			--enable-grub-emu-sdl2=no \
			--enable-grub-mkfont=no \
			--enable-grub-mount=no \
			--enable-grub-themes=no \
			--enable-liblzma=no \
			--enable-libzfs=no \
			--target="i386" && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

grub-clean:
	rm -rf $(GRUB_SRC_DIR)/build
