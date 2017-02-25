#ifndef _TIME_H_
#define _TIME_H_

/* Configures the timer to count 
 * cycles of 0.1 ms
 */
void timer_init(void);

/* Starts a new count */
void timer_start(void);

/* Stops the count and returns
 * the elapsed time modulus 65536
 */
short int timer_stop(void);

#endif

