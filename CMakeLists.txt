cmake_minimum_required(VERSION 3.0.2)

add_executable(avr_demo.elf main.c)
# To inspect COMPILE_FLAGS, enable CMAKE_EXPORT_COMPILE_COMMANDS
# and see compile_commands.json.
# set (CMAKE_EXPORT_COMPILE_COMMANDS OFF)
# To inspect LINK_FLAGS, enable CMAKE_VERBOSE_MAKEFILE
# and manually parse the build output for "Linking C executable". I don't know of a better way.
# set (CMAKE_VERBOSE_MAKEFILE OFF)
set_target_properties(
    avr_demo.elf
    PROPERTIES
        COMPILE_FLAGS "-mmcu=${AVR_MCU} -Wall -Wstrict-prototypes -funsigned-bitfields -funsigned-char -fpack-struct -fshort-enums"
        LINK_FLAGS "-mmcu=${AVR_MCU} -Wl,-Map,avr_demo.map"
)

add_custom_target(
    disassemble
    COMMAND
        # avr-objdump <option(s)> <file(s)>
        # -h, --[section-]headers  Display the contents of the section headers
        # -S, --source             Intermix source code with disassembly
        ${CMAKE_OBJDUMP} -h -S avr_demo.elf > avr_demo.lst
    DEPENDS
        avr_demo.elf
)

# use find_program?
add_custom_target(
    size
    COMMAND
        ${AVR_SIZE} avr_demo.elf
    DEPENDS
        avr_demo.elf
)

# This should actually be a custom_command? This works for now.
# custom targets can be made directly (make hex)
# but they are always considered out-of-date; the hex image will be rebuilt every time!
add_custom_target(
    hex
    COMMAND
        # avr-objcopy [option(s)] in-file [out-file]
        # -j --only-section <name>         Only copy section <name> into the output
        # -O --output-target <bfdname>     Create an output file in format <bfdname>
        ${CMAKE_OBJCOPY} -j .text -j .data -O ihex avr_demo.elf avr_demo.hex
    DEPENDS
        avr_demo.elf
)
