cmake_minimum_required(VERSION 3.21)
project(embed)

# Options
option(BUILD_EXAMPLES "Build examples" ${PROJECT_IS_TOP_LEVEL})
option(BUILD_TESTS "Build tests" ${PROJECT_IS_TOP_LEVEL})

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