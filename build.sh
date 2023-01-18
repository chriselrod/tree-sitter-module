#!/bin/bash

set -u
set -e

lang=$1
topdir="$PWD"

if [ "$(uname)" == "Darwin" ]
then
    soext="dylib"
elif uname | grep -q "MINGW" > /dev/null
then
    soext="dll"
else
    soext="so"
fi

echo "Building ${lang}"

### Retrieve sources

org="tree-sitter"
repo="tree-sitter-${lang}"
sourcedir="tree-sitter-${lang}/src"
grammardir="tree-sitter-${lang}"

case "${lang}" in
    "dockerfile")
        org="camdencheek"
        ;;
    "cmake")
        org="uyha"
        ;;
    "typescript")
        sourcedir="tree-sitter-typescript/typescript/src"
        grammardir="tree-sitter-typescript/typescript"
        ;;
    "tsx")
        repo="tree-sitter-typescript"
        sourcedir="tree-sitter-typescript/tsx/src"
        grammardir="tree-sitter-typescript/tsx"
        ;;
    "elixir")
        org="elixir-lang"
        ;;
    "heex")
        org="phoenixframework"
        ;;
    "glsl")
        org="theHamsta"
        ;;
    "make")
        org="alemuller"
        ;;
    "markdown")
        org="ikatyang"
        ;;
    "org")
        org="milisims"
        ;;
    "perl")
        org="ganezdragon"
        ;;
    "proto")
        org="mitchellh"
        ;;
    "sql")
        org="m-novikov"
        ;;
    "toml")
        org="ikatyang"
        ;;
    "vhdl")
        org="alemuller"
        ;;
    "wgsl")
        org="mehmetoguzderin"
        ;;
    "yaml")
        org="ikatyang"
        ;;
esac

if [ ! -d "${repo}" ]
then
    git clone "https://github.com/${org}/${repo}.git" \
        --depth 1 --quiet
    cd "${sourcedir}"
else
    cd "${sourcedir}"
    git pull --quiet
fi
cp "../${grammardir}"/grammar.js grammar.js
# We have to go into the source directory to compile, because some
# C files refer to files like "../../common/scanner.h".

### Build
FLAGS="-O3 -march=native -DNDEBUG -fno-semantic-interposition -fPIC"

cc $FLAGS -c -I. parser.c
# Compile scanner.c.
if test -f scanner.c
then
    cc $FLAGS -c -I. scanner.c
fi
# Compile scanner.cc.
if test -f scanner.cc
then
    c++ $FLAGS -I. -c scanner.cc
fi
# Link.
if test -f scanner.cc
then
    c++ $FLAGS -shared *.o -o "libtree-sitter-${lang}.${soext}"
else
    cc $FLAGS -shared *.o -o "libtree-sitter-${lang}.${soext}"
fi

### Copy out

mkdir -p "${topdir}/dist"
mv "libtree-sitter-${lang}.${soext}" "${topdir}/dist"
cd "${topdir}"
