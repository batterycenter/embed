
#include <iostream>
#include "battery/embed.hpp"

int main() {
    std::cout << b::embed<"another subdir/banner.txt">() << std::endl;
    return 0;
}