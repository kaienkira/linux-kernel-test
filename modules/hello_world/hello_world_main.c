#include <linux/kernel.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");

int init_module(void)
{
    printk(KERN_INFO "Hello World\n");

    return 0;
}

void cleanup_module(void)
{
}
