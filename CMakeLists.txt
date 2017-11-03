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
