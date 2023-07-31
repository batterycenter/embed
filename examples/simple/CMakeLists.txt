
add_executable(simple src/main.cpp)
target_compile_features(simple PRIVATE cxx_std_17)

source_group("src" FILES src/main.cpp)

embed(simple resources/banner.txt TEXT resources_banner)