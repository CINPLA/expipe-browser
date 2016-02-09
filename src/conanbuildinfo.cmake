set(CONAN_CATCH_ROOT "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed")
set(CONAN_INCLUDE_DIRS_CATCH "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include")
set(CONAN_LIB_DIRS_CATCH "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib")
set(CONAN_BIN_DIRS_CATCH "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin")
set(CONAN_LIBS_CATCH )
set(CONAN_DEFINES_CATCH )
set(CONAN_CXX_FLAGS_CATCH "")
set(CONAN_SHARED_LINK_FLAGS_CATCH "")
set(CONAN_EXE_LINKER_FLAGS_CATCH "")
set(CONAN_C_FLAGS_CATCH "")

set(CONAN_H5CPP_ROOT "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed")
set(CONAN_INCLUDE_DIRS_H5CPP "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include")
set(CONAN_LIB_DIRS_H5CPP "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib")
set(CONAN_BIN_DIRS_H5CPP "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin")
set(CONAN_LIBS_H5CPP elegant_hdf5)
set(CONAN_DEFINES_H5CPP )
set(CONAN_CXX_FLAGS_H5CPP "")
set(CONAN_SHARED_LINK_FLAGS_H5CPP "")
set(CONAN_EXE_LINKER_FLAGS_H5CPP "")
set(CONAN_C_FLAGS_H5CPP "")

set(CONAN_INCLUDE_DIRS "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include"
			"/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include" ${CONAN_INCLUDE_DIRS})
set(CONAN_LIB_DIRS "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib"
			"/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib" ${CONAN_LIB_DIRS})
set(CONAN_BIN_DIRS "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin"
			"/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin" ${CONAN_BIN_DIRS})
set(CONAN_LIBS elegant_hdf5 ${CONAN_LIBS})
set(CONAN_DEFINES  ${CONAN_DEFINES})
set(CONAN_CXX_FLAGS " ${CONAN_CXX_FLAGS}")
set(CONAN_SHARED_LINK_FLAGS " ${CONAN_SHARED_LINK_FLAGS}")
set(CONAN_EXE_LINKER_FLAGS " ${CONAN_EXE_LINKER_FLAGS}")
set(CONAN_C_FLAGS " ${CONAN_C_FLAGS}")
set(CONAN_CMAKE_MODULE_PATH "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed" "/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed" ${CONAN_CMAKE_MODULE_PATH})
macro(CONAN_BASIC_SETUP)
    conan_check_compiler()
    conan_output_dirs_setup()
    conan_flags_setup()
    # CMake can find findXXX.cmake files in the root of packages
    set(CMAKE_MODULE_PATH ${CONAN_CMAKE_MODULE_PATH} ${CMAKE_MODULE_PATH})
endmacro()

macro(CONAN_FLAGS_SETUP)
    include_directories(${CONAN_INCLUDE_DIRS})
    link_directories(${CONAN_LIB_DIRS})
    add_definitions(${CONAN_DEFINES})

    # For find_library
    set(CMAKE_INCLUDE_PATH ${CONAN_INCLUDE_DIRS} ${CMAKE_INCLUDE_PATH})
    set(CMAKE_LIBRARY_PATH ${CONAN_LIB_DIRS} ${CMAKE_LIBRARY_PATH})

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CONAN_CXX_FLAGS}")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CONAN_C_FLAGS}")
    set(CMAKE_SHARED_LINK_FLAGS "${CMAKE_SHARED_LINK_FLAGS} ${CONAN_SHARED_LINK_FLAGS}")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CONAN_EXE_LINKER_FLAGS}")

    if(APPLE)
        # https://cmake.org/Wiki/CMake_RPATH_handling
        # CONAN GUIDE: All generated libraries should have the id and dependencies to other
        # dylibs without path, just the name, EX:
        # libMyLib1.dylib:
        #     libMyLib1.dylib (compatibility version 0.0.0, current version 0.0.0)
        #     libMyLib0.dylib (compatibility version 0.0.0, current version 0.0.0)
        #     /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 120.0.0)
        #     /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1197.1.1)
        set(CMAKE_SKIP_RPATH 1)  # AVOID RPATH FOR *.dylib, ALL LIBS BETWEEN THEM AND THE EXE
                                 # SHOULD BE ON THE LINKER RESOLVER PATH (./ IS ONE OF THEM)
    endif()
    if(CONAN_LINK_RUNTIME)
        string(REPLACE "/MD" ${CONAN_LINK_RUNTIME} CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
        string(REPLACE "/MDd" ${CONAN_LINK_RUNTIME} CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
        string(REPLACE "/MD" ${CONAN_LINK_RUNTIME} CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})
        string(REPLACE "/MDd" ${CONAN_LINK_RUNTIME} CMAKE_C_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
    endif()
endmacro()

macro(CONAN_OUTPUT_DIRS_SETUP)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
endmacro()

macro(CONAN_CHECK_COMPILER)
    if("${CONAN_COMPILER}" STREQUAL "Visual Studio")
        if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL MSVC)
            message(FATAL_ERROR "The current compiler is not MSVC")
        endif()
    elseif("${CONAN_COMPILER}" STREQUAL "gcc")
        if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
             message(FATAL_ERROR "The current compiler is not GCC")
        endif()
        string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${CMAKE_CXX_COMPILER_VERSION})
        list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
        list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)
        if(NOT ${GCC_MAJOR}.${GCC_MINOR} VERSION_EQUAL "${CONAN_COMPILER_VERSION}")
           message(FATAL_ERROR "INCORRECT GCC VERSION CONAN=" ${CONAN_COMPILER_VERSION}
                               " CURRENT GCC=" ${GCC_MAJOR}.${GCC_MINOR})
        endif()
    elseif("${CONAN_COMPILER}" STREQUAL "clang")
        # TODO, CHECK COMPILER AND VERSIONS, AND MATCH WITH apple-clang TOO
    endif()

endmacro()
