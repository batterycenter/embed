
#include <iostream>
#include "battery/embed.hpp"

int main() {
    std::cout << "An icon file called 'worldwide.png' was embedded." << std::endl;
    std::cout << "Filesize: " << b::embed<"resources/worldwide.png">().size() << " bytes" << std::endl;
    return 0;
}