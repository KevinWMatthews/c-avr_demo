# Load this Toolchain file for an out-of-source build using:
#   cmake -DCMAKE_TOOLCHAIN_FILE=Toolchain-avr-ATtiny861.cmake ..
set (AVR_MCU "attiny861")
set (AVR_TOOLCHAIN_HOME /home/kmatthews/coding/toolchains/avr8-gnu-toolchain-linux_x86_64)

set (CMAKE_SYSTEM_NAME Generic)
set (CMAKE_C_COMPILER ${AVR_TOOLCHAIN_HOME}/bin/avr-gcc)
set (CMAKE_CXX_COMPILER ${AVR_TOOLCHAIN_HOME}/bin/avr-g++)
set (AVR_SIZE ${AVR_TOOLCHAIN_HOME}/bin/avr-size)

set (CMAKE_FIND_ROOT_PATH ${AVR_TOOLCHAIN_HOME})
set (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
