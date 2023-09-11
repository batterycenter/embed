
#include <iostream>
#include "battery/embed.hpp"

int main() {
    std::cout << "This is: \n" << b::embed<"resources/banner.txt">() << std::endl;
    return 0;
}