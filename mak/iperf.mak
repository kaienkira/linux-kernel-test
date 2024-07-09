IPERF_SRC_DIR = $(abspath src/iperf-3.17.1)

.PHONY: \
iperf-build \
iperf-clean \
iperf-compile \
iperf-install

iperf-build: iperf-compile iperf-install

iperf-clean:
	rm -rf $(IPERF_SRC_DIR)/build

iperf-compile:
	mkdir -p $(IPERF_SRC_DIR)/build
	cd $(IPERF_SRC_DIR)/build && \
		../configure \
			CFLAGS="-O2 -I$(INSTALL_DIR)/include" \
			LDFLAGS="-L$(INSTALL_DIR)/lib" \
			--prefix=/ \
			--without-sctp \
			--without-openssl && \
		make -j$(NPROC) && \
		mkdir -p _install && \
		make DESTDIR=`readlink -f _install` install

iperf-install:
	cp -P $(IPERF_SRC_DIR)/build/_install/lib/libiperf.so* \
		$(INSTALL_DIR)/lib/
	cp -P $(IPERF_SRC_DIR)/build/_install/bin/iperf3 \
		$(INSTALL_DIR)/bin/
