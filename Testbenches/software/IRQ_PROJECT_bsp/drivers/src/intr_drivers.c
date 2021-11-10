
#include <system.h>
#include <alt_types.h>
#include <io.h>

void interrupt_hw_ack(void)
{
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,8,1);
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,8,0);
}

void ir_timer(alt_u32 ir_data)
{
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,4,ir_data);
}

void print_ir_data(void)
{
	alt_u32 ir_freq;

	ir_freq= IORD_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,0);
	printf("Sent interrupt = %d\n",ir_freq);

}
