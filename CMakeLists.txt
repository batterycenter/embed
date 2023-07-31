cmake_minimum_required(VERSION 3.21)
project(embed)

# Options
option(BUILD_EXAMPLES "Build examples" ${PROJECT_IS_TOP_LEVEL})
# set EMBED_ADDITIONAL_HEADER_FILES (list): Additional header files to be included in generated files (just the name + extension). 
#    Example: "iostream;myString.h"
# set EMBED_ADDITIONAL_STRING_CLASSES (list): Additional string classes to generate operators for (operators are automatically generated)
#    Example: "std::string;my::string"
# set EMBED_ADDITIONAL_OPERATORS (list): Additional member functions or operators for converting to custom types. 
#    Example: "inline operator MyString1() { return MyString1(m_data)\; };inline operator MyString2() { return MyString2(m_data)\; }"

# Define the actual embedding tool
include(cmake/embed.cmake)

# Build all examples
if (BUILD_EXAMPLES)
    add_subdirectory(examples)      # Set Example 'simple' as the default project in Visual Studio
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT simple)
endif()

# Build all tests
if (BUILD_TESTS)
    add_subdirectory(tests)
endif()

if (PROJECT_IS_TOP_LEVEL)
    set(PREDEFINED_TARGETS_FOLDER "CMakePredefinedTargets")
endif()