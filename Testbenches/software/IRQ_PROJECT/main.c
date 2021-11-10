/*****************************************************************************
 *  Company  : AGSTU AB         *                                            *
 ********************************                                            *
 *  Engineer : Ashraf Tumah     *                                            *
 *  Date     : 21-09-12         *                                            *
 *  Task     : IRQ_Project      *                                            *
 ********************************                                            *
 *   Description:                                                            *
 *      Main filen för validering av IRQ systemet. Skriver punkt             *
 *       för att visa att CPUn arbeter                                       *
 *                                                                           *
 *       ISR anropar "IRQ" och skriver data för antal sända                  *
 *         interrupt i konsolfönstret. Där efter görs en acknowledge         *
 *         till både nios cpu och hårdvarukomponenten                        *
 *                                                                           *
 *****************************************************************************/

#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include "altera_avalon_pio_regs.h"
#include <alt_types.h>
#include <io.h>
#include <HAL/inc/sys/alt_irq.h>


//Declare ISR
static void handle_interrupt(void *pContext);

//Declare Global Variable
static ir_freq;
int main()
{
	//Säkerställa återställd ack-signal//
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,8,1);
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,8,0);
    //--------------------------------//

	/*Skriva till Interrupt kontrollern
	50000000 = 1 sec avbrottsintervall*/
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,4,50000000);
	//-------------------------------//

	int *pContext;
	printf("Start\n");


	//Registrera ISR
	if (alt_ic_isr_register(0,0, handle_interrupt, *pContext, 0x0)){ //IRQ och IRQ ID = 0
		printf("Error Reg IRQ");
	}

	while(1)
	{
		// "." för att visa att CPUn arbetar//
		printf(".");
		for(size_t i=0;i<1000000;i++);
	}
}

static void handle_interrupt(void *pContext)
{
	//Verifiera IRQ
	printf("IRQ ");

	/* Antal IRQs registrerade i HW
	   Läs data från interrupt kontrollern*/
	ir_freq= IORD_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,0);
	printf("Sent interrupt = %d\n",ir_freq);

	//HW-ACK//
	// Isr = DOne, Återställ IRQ//
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,8,1);
	IOWR_32DIRECT(INTERRUPT_CONTROLLER_IP_0_BASE,8,0);
	/*************/
}
