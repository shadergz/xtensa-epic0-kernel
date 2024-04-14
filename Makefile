TOOLCHAIN = xtensa-esp32-elf-

CFLAGS_PLATFORM  = -mlongcalls -mtext-section-literals -fstrict-volatile-bitfields
ASFLAGS_PLATFORM = $(CFLAGS_PLATFORM)
LDFLAGS_PLATFORM = $(CFLAGS_PLATFORM)

CC = $(TOOLCHAIN)gcc
LD = $(TOOLCHAIN)ld
OC = $(TOOLCHAIN)objcopy
OS = $(TOOLCHAIN)size

LDSCRIPT = esp32_layout.ld
CFLAGS += $(INC) -Wall -Werror -std=gnu11 -nostdlib $(CFLAGS_PLATFORM) $(COPT)
CFLAGS += -fno-strict-aliasing
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += -Os -g
LDFLAGS += -nostdlib -T$(LDSCRIPT) -Wl,-Map=$@.map -Wl,--cref -Wl,--gc-sections
LDFLAGS += $(LDFLAGS_PLATFORM)
LDFLAGS += -lm -lc -lgcc
ASFLAGS += -c -O0 -Wall -fmessage-length=0
ASFLAGS += $(ASFLAGS_PLATFORM)

C_SRC += \
	./cpu0_soc.c

OBJS += $(C_SRC:.c=.o)

EPIC0_PRE=init
EPIC0_POST=epic0_kernel

ESP32_PORT=/dev/ttyACM0


.PHONY: all
all: $(EPIC0_PRE) 
	esptool.py --chip esp32 elf2image --flash_mode="dio" --flash_freq "40m" --flash_size "4MB" -o $(EPIC0_POST) $<

	@if [ -e $(EPIC0_POST) ]; then\
		esptool.py --chip esp32 --port $(ESP32_PORT) --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 $(EPIC0_POST);\
	fi

%.o: %.S
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@
%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

$(EPIC0_PRE): $(OBJS)
	$(CC) $^ $(LDFLAGS) -o $@

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f $(EPIC0_PRE)*
	rm -f $(EPIC0_POST)
