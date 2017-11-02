# Set this to @ to keep the makefile quiet
ifndef SILENCE
	SILENCE =
endif

###############################
### Target-Specific Details ###
###############################
TARGET_NAME=avr_demo

#mcu type according to avr-gcc
MCU=attiny861

#Root directory of the project as a whole, which may not be the current directory
ROOT_DIR=.
SRC_DIRS=.
INC_DIRS=.
#TODO LIB_DIRS=
#Static lirary names without 'lib' prefix and .a suffix
#TODO LIBS_LIST=
OBJ_DIR=obj
TARGET_DIR=build

#Specify specific source files that aren't in the above directories (hopefully a very temporary situation)
SRC_FILES=

#Optimization level
#use s (size opt), 1, 2, 3, 0 (off), fast, g (debugging)
OPTLEVEL=s

########################
### AVR Dude options ###
########################
#Fill in the part number that avrdude uses
AVRDUDE_MCU=t861

AVRDUDE_PROGRAMMERID=avrispmkII

#port to which your debugger is attached
AVRDUDE_PORT=usb



#########################
#########################
### Basic Config Done ###
#########################
#########################
#All basic project configuration is above this line
#Look below to find compiler options



######################
### Compiler Tools ###
######################
C_COMPILER=avr-gcc
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
SIZE=avr-size
AVRDUDE=avrdude
REMOVE=rm -rf


#############
### Flags ###
#############
HEX_FORMAT=ihex

C_COMPILER_FLAGS=-g -mmcu=$(MCU) -O$(OPTLEVEL) \
	-Wall -Wstrict-prototypes                    \
	-funsigned-bitfields -funsigned-char         \
	-fpack-struct -fshort-enums                  \
#	-Wa,-ahlms=$(firstword $(filter %.lst, $(<:.c=.lst)))

INCLUDE_FLAGS=$(addprefix -I,$(INC_DIRS))

#TODO add in library support
#use  -lm $(LIBS) ?
LINKER_FLAGS=-Wl,-Map,$(TARGET_DIR)/$(TARGET_NAME).map -mmcu=$(MCU)



###################
###################
### Config Done ###
###################
###################
#Edit below this mark only if:
#  You're adding a new makefile feature
#  You found a makefile bug
#  You're overconfident


#############################
### Auto-generated values ###
#############################
TARGET=$(TARGET_DIR)/$(TARGET_NAME).elf
DUMP_TARGET=$(TARGET_NAME).s

HEX_ROM_TARGET=$(TARGET_DIR)/$(TARGET_NAME).hex
HEX_TARGET=$(HEX_ROM_TARGET)

SRC=$(call get_src,$(SRC_DIRS)) $(call clean_path,$(SRC_FILES))
OBJ=$(call clean_path,$(addprefix $(OBJ_DIR)/,$(call src_to_o,$(SRC))))
INC=$(call get_inc,$(INC_DIRS))
LIBS=$(addprefix lib,$(addsuffix .a,$(LIB_LIST)))
LST=$(call src_to_lst,$(SRC))



########################
### Helper Functions ###
########################
#easy to use with colors!
ECHO=@echo -e
#"test" echo; used for checking makefile parameters
techo=$(ECHO) "${BoldPurple}  $1:${NoColor}"; echo $2; echo;

get_src = $(call clean_path,$(call get_src_from_dir_list,$1))
get_src_from_dir_list = $(foreach dir, $1, $(call get_src_from_dir,$(dir)))
get_src_from_dir = $(wildcard $1/*.c) $(wildcard $1/*.cpp)

get_inc = $(call clean_path,$(call get_inc_from_dir_list,$1))
get_inc_from_dir_list = $(foreach dir, $1, $(call get_inc_from_dir,$(dir)))
get_inc_from_dir = $(wildcard $1/*.h)

#clean_path will only remove two subdirectories
#Hahahaha, nest calls because I'm too dumb to figure out how to loop it
clean_path = $(call remove_dotdot,$(call remove_dotdot,$(call remove_dot,$1)))
remove_dotdot = $(patsubst ../%,%,$1)
remove_dot = $(patsubst ./%,%,$1)

src_to_o = $(call src_to,.o,$1)
src_to_s = $(call src_to,.s,$1)
src_to_lst = $(call src_to,.lst,$1)
src_to = $(patsubst %.c,%$1,$2)



####################
### Target Names ###
####################
.PHONY: all install writeflash hex disasm stats clean help

all: $(TARGET)

install: writeflash

writeflash: hex
	sudo $(AVRDUDE) -c $(AVRDUDE_PROGRAMMERID) -p $(AVRDUDE_MCU) -P $(AVRDUDE_PORT) \
             -e -U flash:w:$(HEX_TARGET)

hex: $(HEX_TARGET)

disasm: $(DUMP_TARGET) stats

stats: $(TARGET)
	$(OBJDUMP) -h $(TARGET)
	$(SIZE) $(TARGET)

clean:
	$(REMOVE) $(TARGET_DIR)
	$(REMOVE) $(OBJ_DIR)


### Generate files ###
#Create .elf and .map files
$(TARGET): $(OBJ)
	$(SILENCE)mkdir -p $(dir $@)
	$(C_COMPILER) $(LINKER_FLAGS) -o $(TARGET) $(OBJ)

#Create disassembly for executable
$(DUMP_TARGET): $(TARGET)
	$(OBJDUMP) -S $< > $(TARGET_DIR)/$@


#Generate production code object files
$(OBJ_DIR)/%.o: $(ROOT_DIR)/%.c
	$(SILENCE)mkdir -p $(dir $@)
	$(C_COMPILER) $(C_COMPILER_FLAGS) $(INCLUDE_FLAGS) -c $< -o $@

#Generate hwDemo object files
$(OBJ_DIR)/%.o: %.c
	$(SILENCE)mkdir -p $(dir $@)
	$(C_COMPILER) $(C_COMPILER_FLAGS) $(INCLUDE_FLAGS) -c $< -o $@

##Generate hwDemo assembly
$(OBJ_DIR)/%.s: %.c
	$(SILENCE)mkdir -p $(dir $@)
	$(C_COMPILER) -S $(C_COMPILER_FLAGS) $< -o $@

#Chip-readable .hex file from compiler's binary file output, .elf
%.hex: %.elf
	$(SILENCE)mkdir -p $(dir $@)
	$(OBJCOPY) -j .text -j .data -O $(HEX_FORMAT) $< $@


### Targets for Makefile debugging ###
filelist:
	$(call techo,TARGET,$(TARGET))
	$(call techo,HEX_TARGET,$(HEX_TARGET))
	$(call techo,DUMP_TARGET,$(DUMP_TARGET))
	$(call techo,SRC,$(SRC))
	$(call techo,OBJ,$(OBJ))
	$(call techo,INC,$(INC))
	$(call techo,LST,$(LST))
	$(call techo,LIBS,$(LIBS))

flags:
	$(call techo,C_COMPILER_FLAGS,$(C_COMPILER_FLAGS))
	$(call techo,INCLUDE_FLAGS,$(INCLUDE_FLAGS))
	$(call techo,LINKER_FLAGS,$(LINKER_FLAGS))

help:
	$(ECHO) "all        Compile and link all source code, generate an .elf file (binary)."
	$(ECHO) "install    Create an Intel Hex file from the .elf and write it to chip's flash."
	$(ECHO) "writeflash Same as install."
	$(ECHO) "hex        Generate Intel Hex file only."
	$(ECHO) "disasm     Generate disassembly."
	$(ECHO) "stats      Generate size and disassembly."
	$(ECHO) "flags      Display all flags used during the compilation process."
	$(ECHO) "filelist   List all files detected and created by the makefile."
	$(ECHO) "clean      Remove all files and folders that are generated by this makefile."
	$(ECHO) "help       This."


### Color codes ###
Blue       =\033[0;34m
BoldBlue   =\033[1;34m
Gray       =\033[0;37m
DarkGray   =\033[1;30m
Green      =\033[0;32m
BoldGreen  =\033[1;32m
Cyan       =\033[0;36m
BoldCyan   =\033[1;36m
Red        =\033[0;31m
BoldRed    =\033[1;31m
Purple     =\033[0;35m
BoldPurple =\033[1;35m
Yellow     =\033[0;33m
BoldYellow =\033[1;33m
BoldWhite  =\033[1;37m
NoColor    =\033[0;0m
NC         =\033[0;0m
