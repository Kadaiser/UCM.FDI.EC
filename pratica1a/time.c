#include "time.h"

/* Reloj del sistema */
#define MCLK 64000000

/* WATCHDOG */
#define rWTCON		(*(volatile unsigned *)0x1d30000)
#define rWTDAT		(*(volatile unsigned *)0x1d30004)
#define rWTCNT		(*(volatile unsigned *)0x1d30008)

void timer_init(void)
{
	// freq=MCLK/(P+1)/D => P = MCLK/(freq*D) - 1
	// freq=2000 (2KHz T=0.5ms) D=128 P= MCLK/(128*2000) - 1
	// Max count = 65535*0.5ms = 37 segundos (aprox)
	rWTCON=((MCLK/256000-1)<<8)|(3<<3);
}

void timer_start(void)
{
	rWTDAT=0xffff;
	rWTCNT=0xffff;	 
	rWTCON |= (1<<5); 
}

short int timer_stop(void)
{
	rWTCON &= ~(1<<5);
	return (0xffff-rWTCNT);
}

