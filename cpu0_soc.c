#include <string.h>
#include <stdint.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef int32_t i32;
typedef uint32_t u32;

extern u32 _sbss, _ebss, _sidata, _sdata, _edata;

i32 loop_count = 0;
const i32 loop_ctrl = 1;

#define GPIO_ENABLE_REG 0x3FF44020
#define GPIO_OUT_W1TS_REG 0x3FF44008
#define GPIO_OUT_W1TC_REG 0x3FF4400C

#define RTC_CNTL_STATE0_REG 0x3FF48018

#define GPIO_PAD 1 << 27

int cpu0(void) {
	*(u32*)(GPIO_ENABLE_REG) = GPIO_PAD;
	if ((*(u32*)(RTC_CNTL_STATE0_REG)) & (1 << 29))
		*(u32*)(GPIO_OUT_W1TS_REG) = GPIO_PAD;
	while (loop_ctrl)
		loop_count++;

	return 0;
}

void __attribute__((noreturn)) call_start_cpu0()
{
	memset(&_sbss, 0, (&_ebss - &_sbss) * sizeof(_sbss));
	memmove(&_sdata, &_sidata, (&_edata - &_sdata) * sizeof(_sdata));
	
	cpu0();
	while(1) {}
}
