#define __MICROBLAZE__
#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"
#include <stdio.h>

#define LED_BASE    XPAR_LED_EFFECTS_IP_0_BASEADDR
#define CLOCK_HZ    100000000UL
#define SPEED(hz)   (CLOCK_HZ / (hz))

void led_set_mode(u32 mode)           { Xil_Out32(LED_BASE + 0x00, mode);         }
void led_set_speed(u32 speed_cycles)  { Xil_Out32(LED_BASE + 0x04, speed_cycles); }
void led_set_brightness(u32 b)        { Xil_Out32(LED_BASE + 0x08, b);            }
void led_enable(u32 en)               { Xil_Out32(LED_BASE + 0x0C, en);           }

int main()
{
    while (1)
    {
        int mode, speed, brightness;

        if (scanf("%d", &mode)      != 1 || mode < 0 || mode > 3)         mode       = 1;
        if (scanf("%d", &speed)     != 1 || speed < 1 || speed > 100)     speed      = 2;        //default values in case input is wrong
        if (scanf("%d", &brightness)!= 1 || brightness < 0 || brightness > 255) brightness = 128;

        led_enable(0);
        led_set_mode((u32)mode);
        led_set_speed(SPEED((u32)speed));
        led_set_brightness((u32)brightness);
        led_enable(1);
    }

    return 0;
}
