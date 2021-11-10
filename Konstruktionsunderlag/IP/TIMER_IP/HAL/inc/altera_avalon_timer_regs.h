/*
 * altera_avalon_timer_regs.h
 *
 *  Created on: 26 okt. 2020
 *      Author: Ashraf Tumah
 */

#ifndef ALTERA_AVALON_TIMER_REGS_H_     /* if this file has been read by the linker
before, the #define below */
#define ALTERA_AVALON_TIMER_REGS_H_    // linker will skip all times until the next

#include <io.h>                        // include HAL macros
#include <system.h>                   // include bas address definitions

//define device driver macros
#define TIMER_STOP IOWR_32DIRECT(TIMER_HW_IP_0_BASE,4,0x00000000) //write to control registers
#define TIMER_RESET IOWR_32DIRECT(TIMER_HW_IP_0_BASE,4,0x40000000) // --- | | ---
#define TIMER_START IOWR_32DIRECT(TIMER_HW_IP_0_BASE,4,0X80000000) // --- | | ---
#define TIMER_READ IORD_32DIRECT(TIMER_HW_IP_0_BASE,0) //Read from data register
#endif //ALTERA_AVALON_TIMER_REGS_H  //This ends the #ifndef
