# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-src"
  "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-build"
  "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-subbuild/fmt-populate-prefix"
  "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-subbuild/fmt-populate-prefix/tmp"
  "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-subbuild/fmt-populate-prefix/src/fmt-populate-stamp"
  "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-subbuild/fmt-populate-prefix/src"
  "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-subbuild/fmt-populate-prefix/src/fmt-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-subbuild/fmt-populate-prefix/src/fmt-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/dorian/Documents/chps/TOP25/mesh/build/_deps/fmt-subbuild/fmt-populate-prefix/src/fmt-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
