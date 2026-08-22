cmake_minimum_required(VERSION 3.31)
project(dcsext)

# Define a custom helper for multi-choice configurations
function(add_choice_option VARIABLE DEFAULT_VALUE DESCRIPTION)
	# 1. Create the standard string cache variable
	set(${VARIABLE} "${DEFAULT_VALUE}" CACHE STRING "${DESCRIPTION}")

	# 2. Assign the allowed choices to the GUI property
	set_property(CACHE ${VARIABLE} PROPERTY STRINGS ${ARGN})

	# 3. Enforce strict validation on the current value
	if(NOT ${VARIABLE} IN_LIST ARGN)
		string(REPLACE ";" ", " PRINTABLE_LIST "${ARGN}")
		message(FATAL_ERROR "Invalid ${VARIABLE}: '${${VARIABLE}}'. \nAllowed choices are: [${PRINTABLE_LIST}]")
	endif()
endfunction()

add_choice_option(CMAKE_BUILD_TYPE "Release"
	"Choose the build type"
	"Release" "Debug"
)

# Set default visibility of all symbols to hidden
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)

include(GenerateExportHeader)
include(CheckPIESupported)

# check for PIE support in the linker
check_pie_supported()

if(WIN32)
	# custom lua5.1 library definition
	# Define paths inside the build output directory
	set(DEF_FILE "${CMAKE_CURRENT_SOURCE_DIR}/win32-lua/lua51.def")
	set(STUB_LIB "${CMAKE_CURRENT_BINARY_DIR}/liblua51.dll.a")

	# Define the rule to generate the stub file using the toolchain's
	# dlltool
	add_custom_command(
		OUTPUT "${STUB_LIB}"
		COMMAND ${TOOLCHAIN_PREFIX}-dlltool -d "${DEF_FILE}" -l "${STUB_LIB}" -m i386:x86-64
		DEPENDS "${DEF_FILE}"
		COMMENT "GEN Lua stub..."
		CODEGEN
		VERBATIM
	)

	# Wrap the custom command in a target so CMake tracks its lifecycle
	add_custom_target(dcs_lua_stub DEPENDS "${STUB_LIB}")
	set(LUA_LIBRARIES "${STUB_LIB}")
endif()

find_package(Lua 5.1 REQUIRED)
if(Lua_FOUND AND NOT TARGET Lua51::Lua51)
	add_library(Lua51::Lua51 INTERFACE IMPORTED)
	set_target_properties(Lua51::Lua51 PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES "${LUA_INCLUDE_DIR}"
		INTERFACE_LINK_LIBRARIES "${LUA_LIBRARIES}"
	)
endif()

if(WIN32)
	add_dependencies(Lua51::Lua51 dcs_lua_stub)
endif()

# Define the lua C extension
add_library(dcsext_math MODULE)
target_compile_features(dcsext_math PUBLIC c_std_17)
target_compile_options(dcsext_math
	PRIVATE
		$<$<C_COMPILER_ID:MSVC>:/W4>
		$<$<NOT:$<C_COMPILER_ID:MSVC>>:-Wall>
)
set_target_properties(dcsext_math PROPERTIES
	PREFIX ""
	OUTPUT_NAME "dcsext_math"
	COMPILE_WARNING_AS_ERROR ON
)

if(CMAKE_C_LINK_PIE_SUPPORTED)
	set_target_properties(dcsext_math PROPERTIES
		INTERFACE_POSITION_INDEPENDENT_CODE ON
	)
endif()

generate_export_header(dcsext_math)
target_sources(dcsext_math
	PRIVATE
		src/math.c
	PUBLIC
		FILE_SET myHeaders
			TYPE HEADERS
			BASE_DIRS include
		FILE_SET generated_headers
			TYPE HEADERS
			BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
			FILES ${CMAKE_CURRENT_BINARY_DIR}/dcsext_math_export.h
)
target_link_libraries(dcsext_math PRIVATE Lua51::Lua51)
