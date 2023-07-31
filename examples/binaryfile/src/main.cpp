
#include <iostream>
#include "Embed/Icon.hpp"

int main() {
    std::cout << "An icon file called 'worldwide.png' was embedded." << std::endl;
    std::cout << "Filesize: " << Embed::Icon.size() << " bytes" << std::endl;
    std::cout << "File is binary: " << (Embed::Icon.isBinary() ? "true" : "false") << std::endl;
    return 0;
}