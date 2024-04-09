
add_executable(subdirectory src/main.cpp)
target_compile_features(subdirectory PRIVATE cxx_std_20)
source_group("src" FILES src/main.cpp)

add_subdirectory(resources)
target_link_libraries(subdirectory PUBLIC subdirectory-resources)