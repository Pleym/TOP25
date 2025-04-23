# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-src"
  "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-build"
  "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-subbuild/kokkoskernels-populate-prefix"
  "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-subbuild/kokkoskernels-populate-prefix/tmp"
  "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-subbuild/kokkoskernels-populate-prefix/src/kokkoskernels-populate-stamp"
  "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-subbuild/kokkoskernels-populate-prefix/src"
  "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-subbuild/kokkoskernels-populate-prefix/src/kokkoskernels-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-subbuild/kokkoskernels-populate-prefix/src/kokkoskernels-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/dorian/Documents/chps/TOP25/matrix-product/build-rr/_deps/kokkoskernels-subbuild/kokkoskernels-populate-prefix/src/kokkoskernels-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
