import jinja2
import argparse
import os
import io
import string

def isPrintable(s):  # This is similar to str.isprintable(), but with \t, \n, and \r allowed
    return all(c in string.printable for c in s)

def main():
    parser = argparse.ArgumentParser(description='Embed a resource into a C++ source file.')
    parser.add_argument('header_target_file', metavar='header_target_file', type=str, help='header target file to generate')
    parser.add_argument('source_target_file', metavar='source_target_file', type=str, help='source target file to generate')
    parser.add_argument('resource_file', metavar='resource_file', type=str, help='resource file to embed')
    parser.add_argument('resource_type', metavar='resource_type', type=str, choices=['TEXT', 'BINARY'], help='how to read the resource file')
    parser.add_argument('identifier', metavar='identifier', type=str, help='identifier to use for the resource')
    parser.add_argument('full_identifier', metavar='full_identifier', type=str, help='identifier including / to use for the resource')
    parser.add_argument('file_identifier', metavar='file_identifier', type=str, help='file identifier without folders to use for the resource')
    parser.add_argument('identifier_namespaces', metavar='identifier_namespaces', type=str, help='just the identifier namespaces with leading :: if any')
    parser.add_argument('--additional-header-files', dest='additional_header_files', type=str, nargs='*', help='additional header files to include')
    parser.add_argument('--additional-string-classes', dest='additional_string_classes', type=str, nargs='*', help='additional string classes to generate operators for')
    parser.add_argument('--additional-operators', dest='additional_operators', type=str, nargs='*', help='additional operators or member functions to generate')
    args = parser.parse_args()

    is_binary = args.resource_type == "BINARY"
    original_resource = io.open(args.resource_file, 'rb' if is_binary else 'r').read()
    if not is_binary:
        if not isPrintable(original_resource):
            raise Exception(f"The file {args.resource_file} contains unprintable characters, but TEXT was specified as resource type. Are you sure you did not mean to write BINARY?")
        original_resource = original_resource.encode('utf-8')

    resource_as_hex_array = ", ".join(["'\\x{:02x}'".format(b) for b in original_resource])

    if args.identifier_namespaces == "None":
        args.identifier_namespaces = ""

    data = {
        "identifier": args.identifier,
        "full_identifier": args.full_identifier,
        "file_identifier": args.file_identifier,
        "identifier_namespaces": args.identifier_namespaces,
        "filename": os.path.basename(args.resource_file),
        "resource_path": args.resource_file,
        "resource_hex": resource_as_hex_array,
        "resource_size": len(original_resource),
        "is_binary": is_binary,
        "additional_header_files": args.additional_header_files,
        "additional_string_classes": args.additional_string_classes,
        "additional_operators": args.additional_operators
    }

    template = jinja2.Template(io.open("templates/header.hpp", 'r').read())
    open(args.header_target_file, 'w').write(template.render(data))

    template = jinja2.Template(io.open("templates/source.cpp", 'r').read())
    open(args.source_target_file, 'w').write(template.render(data))

if __name__ == "__main__":
    main()