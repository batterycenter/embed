
add_executable(binaryfile src/main.cpp)
target_compile_features(binaryfile PRIVATE cxx_std_20)
source_group("src" FILES src/main.cpp)

b_embed(binaryfile resources/worldwide.png)