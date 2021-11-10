/*
 * intr_drivers.h
 *
 *  Created on: 17 sep. 2021
 *      Author: ashra
 */

#ifndef INTR_DRIVERS_H_
#define INTR_DRIVERS_H_

#define SEC_1  50000000
#define SEC_5  250000000
#define SEC_10 500000000


void interrupt_hw_ack(void);

void ir_timer(alt_u32 ir_data);

void print_ir_data(void);

#endif /* INTR_DRIVERS_H_ */
