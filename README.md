# battery-embed

Embedding files into executables made easy. Minimal CMake, Modern C++, a minute of setup time. What else?

## What this is

This is a CMake-based C++ library that allows you to very easily embed resource files into your executable. It is meant to be used for files such as icons, images, shader code, configuration files, etc.. You don't have to worry about distributing them with your application as the files are part of the application once compiled. It might also be an advantage that an end user cannot modify the files once shipped. You can develop your application data in conventional files in your favourite text editor (your IDE) and don't have to deal with multi-line C++ strings or converting files using external tool. Conversion is fully automatic.

This library is developed in the context of [Battery](https://github.com/batterycenter/battery). The feature set might make more sense in the bigger picture of Battery. However, it is designed to be used as a standalone library for any of your projects, that do not use Battery. Feel free to use it in any of your projects.

## What this is NOT

There exists another library at https://github.com/MKlimenko/embed, it is considered to be a reference implementation of [std::embed](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1040r6.html). However, `std::embed` is still far away, so we have to improvise. `Battery-embed` has nothing to do with `std::embed` as it serves its own purpose, although it might deprecate when `std::embed` finally makes its way into the standard.

## You can embed ...

... files that are easier to write in a text editor in comparison to multi-line C-strings, or binary files, that would be a burden to ship with the portable application, that is:

 - Text files such as
   - text messages, ASCII art
   - small configuration files such as default settings in json, XML, etc..
   - templating files for generating files like jinja (or more like [inja]())
   - shader code, base-64 encoded data that is too long for C++ strings
 - Binary files such as
   - images, icons or splash screens
   - color palette files
   - language/localization files
   - audio files

What is NOT to be embedded:  
- Very large files (>50Mb), as this bloats the executable size and will take forever to compile. In some cases it might not even compile because the compiler needs too much RAM to compile the gigabytes of char-arrays. They are recommended to be shipped with the application and loaded at runtime.
- Or files that are to be modified at runtime, by the end user or other applications.

## How it works

`Battery-embed` uses Python to generate the files. You can use `embed_text()` and `embed_binary()` in CMake to mark files for embedding. Then, when building your project, the files are automatically converted to C++ byte arrays and added to your project. Also, it automatically regenerates whenever the file changes. Then, the source is compiled and linked into your application and you can access it like if it was a simple string, but without the hassle of writing dozens of multi-line C++ strings.

`MKlimenko/embed` has a different approach, it builds a C++ CLI app and compiles it as part of your application, and then calls it to generate the files, doing the conversion in C++. `Battery-embed` also used this approach in the beginning, but this makes cross-compilation almost impossible, as the compiler might be for a different architecture and cannot run on the host, and having two different compilers in the same CMake project is just asking for trouble. 

`Battery-embed` is designed to stay out of your way when developing, so it will allow cross-compilation just as well. It is not yet optimized for speed, however.

Advantages over `MKlimenko/embed`:

 - Much simpler design and easier to use
 - Only a single line of CMake per file
 - Resource files are nicely named and can be accessed by an identifier, not an index
 - Files can be nicely organized in folders, and the folder structure can even be preserved all the way down to the usage code
 - Cross-compilation without any issues

# Building the Examples

Building the examples:

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

Locate the built executable in the `build` directory (location depends on your compiler) and run it in a terminal.

# Example usage

## Getting the library

There are three ways to get the library:

### 1. Use [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) or [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake.git) to let CMake download it on-demand (Recommended)

```cmake
FetchContent_Declare(
  battery-embed
  GIT_REPOSITORY https://github.com/batterycenter/embed.git
  GIT_TAG        v1.0.0
)
FetchContent_MakeAvailable(battery-embed)
```

Or, if you use `CPM.cmake`:

```cmake
CPMAddPackage("gh:batterycenter/embed@v1.0.0")
```

Make sure to use the git tag of the latest release, but not 'main', to make sure your project stays reproducible for a long time and does not break by itself at some point.

### 2. Use git submodules or place the library itself in your repository

```bash
git submodule add https://github.com/batterycenter/embed external/embed
```

This adds it to your repository as a submodule, it is automatically cloned when you clone your repository using `git clone --recursive`. You can also just copy the library into your repository, but then you have to make sure to update it manually. See the License when doing that.

In both cases, just add the subdirectory:
```cmake
add_subdirectory(external/embed)
```

### 3. Conan (not planned yet)

This library does not have Conan support yet. Let me know if there is interest to add this library to Conan!

## CMake API (Binary files and Line endings)

Three functions exist for you. These are the main two:

```cmake
embed_text(MyTargetName resources/text_file.txt MyTextFile)
embed_binary(MyTargetName resources/icon.png Icon)
```

In the context of this library, text files are human-readable files containing printable characters, such as text messages, configuration files, json files, etc. Binary files are machine-readable files containing arbitrary byte sequences such as images, compressed data, database files, or any files that are not to be supposed to be edited using a text editor.

The difference is important because Line Endings are not the same across platforms. For example, Linux uses LF line endings and Windows uses CRLF. By marking a file as Text, line endings are automatically converted to LF when loading, to ensure consistent line endings on all platforms. However, this will break binary files as the byte sequence is changed.

Embedding a file as Binary, the file is embedded 1 to 1 as-is on byte-basis, keeping the data in binary files such as images valid, but on the other hand bringing CRLF line endings in your application if used on a text file. You usually want to avoid that.

## Embedding a simple text file

Place the file you want to embed into a folder, preferrably named `resources/` in your project's root directory. Then, add the following to your `CMakeLists.txt`:

```cmake
embed_text(<TargetName> resources/my_text_file.txt MyTextFile)
```

This will embed the file under the name `MyTextFile` into the target `<TargetName>`. Then, in C++:

```cpp
#include "Embed/MyTextFile.hpp"

void test() {
    std::cout << Embed::MyTextFile << std::endl;
}
```

Every embedded file lives in the `Embed` namespace, under the name that was assigned to it in CMake.

### Type conversions

`Embed::MyTextFile` is a global instance of a class, that provides a number of functions and operators.

```cpp
std::string file = Embed::MyTextFile.str();
size_t length = Embed::MyTextFile.length();     // or .size()
const char* pointer = Embed::MyTextFile.data();
std::vector<uint8_t> vec = Embed::MyTextFile.vec();
bool isBinary = Embed::MyTextFile.isBinary();
```

And all conversions also exist as operators, allowing for this:

```cpp
void foo1(const std::string& test);
void foo2(const char* test);
void foo3(const std::vector<uint8_t>& test);

foo1(Embed::MyTextFile);
foo2(Embed::MyTextFile);
foo3(Embed::MyTextFile);
```

## Embedding binary files

Exact same procedure as with a text file:

```cmake
embed_binary(<TargetName> resources/icon.png Icon)
```

Then, in C++:

```cpp
#include "Embed/Icon.hpp"

void old_c_style_function(const char* data, unsigned long size);

void test() {
    // Looping through all bytes
    for (uint8_t byte : Embed::Icon.vec()) {
        std::cout << byte << std::endl;
    }

    // Or pass it along
    old_c_style_function(Embed::Icon.data(), Embed::Icon.size());
}
```

Most legacy APIs provide functions to either load files from the filesystem, or from a memory buffer taking a pointer and a size. In this case you can always use the memory variant to achieve the exact same thing, but without actually interacting with the filesystem. Everything is enclosed in the executable itself.

If there is strictly no other way than loading from the filesystem, you can still embed the file and write it to disk when needed, let the legacy API load it, and then delete it again, if you want to keep your application portable and want to avoid shipping resource files.

## Multiple files and namespaces

This library allows you to nicely preserve the tree structure.
Suppose you have many many resource files in a huge project:

```
resources
  - templates
  | - template1.txt
  | - template2.txt
  | - template3.txt
  - images
  | - icon.svg
  | - splash.png
  - many
  | - more
    | - folders
      | - file1.txt
      | - test2.svg
```

This exact tree structure can be represented by using namespaced identifiers:
```cmake
embed_text(MyTarget resources/templates/template1.txt Templates/Template1)
embed_text(MyTarget resources/templates/template2.txt Templates/Template2)
embed_text(MyTarget resources/templates/template3.txt Templates/Template3)

embed_binary(MyTarget resources/images/icon.svg Images/Icon)
embed_binary(MyTarget resources/images/splash.png Images/Splash)

embed_text(MyTarget resources/many/more/folders/file1.txt Many/More/Folders/File1)
embed_text(MyTarget resources/many/more/folders/test2.svg Many/More/Folders/Test2)
```

And now you can access them in C++ using the corresponding namespace:
```cpp
#include "Embed/Templates/Template1.hpp"
#include "Embed/Templates/Template2.hpp"
#include "Embed/Templates/Template3.hpp"

std::cout << Embed::Templates::Template1;
std::cout << Embed::Templates::Template2;
std::cout << Embed::Templates::Template3;

#include "Embed/Images/Icon.hpp"
#include "Embed/Images/Splash.hpp"

std::cout << Embed::Images::Icon.isBinary();
std::cout << Embed::Images::Splash.isBinary();

#include "Embed/Many/More/Folders/File1.hpp"
#include "Embed/Many/More/Folders/Test2.hpp"

std::cout << Embed::Many::More::Folders::File1;
std::cout << Embed::Many::More::Folders::Test2.isBinary();
```

Every CMake call must have a unique namespace/identifier combination. The same identifier is allowed under different namespaces, but every namespace/identifier combination must be unique across the entire solution.

## Custom types and operators

This feature makes sense in the bigger picture of [Battery](https://github.com/batterycenter/battery), but it also might for you. This library allows you to inject code that is placed into the generated header files, to allow automatic conversion operators to your custom string classes, or simply add more functions.

Say you want to provide conversions to `sf::String` and `MyString`:
```cmake
set(EMBED_ADDITIONAL_HEADER_FILES "SFML/System/String.hpp;MyString.h")
set(EMBED_ADDITIONAL_STRING_CLASSES "sf::String;MyString")
```

Now, both headers will be included and conversion operators for both classes will be generated (their constructor must take an std::string).

If you want to do something more advanced, you can also inject an entire operator or function:

```cmake
set(EMBED_ADDITIONAL_OPERATORS 
  "inline operator MyString1() { return MyString1(m_data)\; }"
  "inline operator MyString2() { return MyString2(m_data)\; }"
)
```

Now you can do something more advanced with all access to private variables, or inject other kinds of functions. Make sure to always look at the generated files.
Semicolons must be escaped because they deliminate list elements in CMake.

# Contribution

This library is open for contributions. Feel free to open an issue or a pull request, I am very happy about feedback and ideas to improve it!

# Attribution

The examples contain an icon file that is <a href="https://www.flaticon.com/free-icons/global" title="global icons">provided by Freepik - Flaticon</a>

# License

This project is licensed under the Apache License 2.0. This means that when using the library in a C++ project like it is intended to, you are allowed to do whatever you like, commercial or non-commercial. Compiled binaries that rely on this library as a build dependency do not include substantial parts of this codebase and are therefore independent.

Regarding the library itself, you are allowed to modify it and redistribute it according to the Apache License 2.0. This means you are allowed to re-upload this library as part of your own public repository, but the license file must be retained and any modifications must be clearly marked.

# FAQ

## I get a weird Python error

```bash
Traceback (most recent call last):
    File "C:\Users\zachs\Projects\embed\scripts\embed.py", line 59, in <module>
      main()
    File "C:\Users\zachs\Projects\embed\scripts\embed.py", line 26, in main
      original_resource = io.open(args.resource_file, 'rb' if is_binary else 'r').read()
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    File "C:\Users\zachs\AppData\Local\Programs\Python\Python311\Lib\encodings\cp1252.py", line 23, in decode
      return codecs.charmap_decode(input,self.errors,decoding_table)[0]
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  UnicodeDecodeError: 'charmap' codec can't decode byte 0x81 in position 1017: character maps to <undefined>
```

You are probably trying to embed a binary file using `embed_text()`. Use `embed_binary()` instead or load the correct file.

# TODO/Known issues

- Currently each identifier can only be used once in the entire solution, even across multiple targets. However, there might not be a strict reason to have it this way.