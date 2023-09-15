KDIR = ../../src/linux-*
obj-m := hello_world.o
hello_world-y := hello_world_main.o

default:
	make -C $(KDIR) O=build ARCH=x86 M=$(PWD) modules

clean:
	@rm -f *.o *.ko *.mod *.mod.c modules.order Module.symvers .*.cmd
