#include <iostream>
#include "battery/embed.hpp"

int main() {
    std::cout << "An extracted text file called 'helloworld.txt' was embedded." << std::endl;
    std::cout << "Filesize: " << b::embed<"resources/helloworld.txt">().size() << " bytes" << std::endl;
    return 0;
}
