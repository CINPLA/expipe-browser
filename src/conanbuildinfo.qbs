import qbs 1.0

Project {
    Product {
        name: "ConanBasicSetup"
        Export {
            Depends { name: "cpp" }
            cpp.includePaths: ["/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include",
                "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include"]
            cpp.libraryPaths: ["/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib",
                "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib"]
            cpp.systemIncludePaths: ["/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin",
                "/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin"]
            cpp.dynamicLibraries: ["elegant_hdf5"]
            cpp.defines: []
            cpp.cppFlags: []
            cpp.cFlags: []
            cpp.linkerFlags: []
        }
    }

    Product {
        name: "Catch"
        Export {
            Depends { name: "cpp" }
            cpp.includePaths: ["/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include"]
            cpp.libraryPaths: ["/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib"]
            cpp.systemIncludePaths: ["/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin"]
            cpp.dynamicLibraries: []
            cpp.defines: []
            cpp.cppFlags: []
            cpp.cFlags: []
            cpp.linkerFlags: []
        }
    }
    // Catch root path: /home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed

    Product {
        name: "h5cpp"
        Export {
            Depends { name: "cpp" }
            cpp.includePaths: ["/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include"]
            cpp.libraryPaths: ["/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib"]
            cpp.systemIncludePaths: ["/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin"]
            cpp.dynamicLibraries: ["elegant_hdf5"]
            cpp.defines: []
            cpp.cppFlags: []
            cpp.cFlags: []
            cpp.linkerFlags: []
        }
    }
    // h5cpp root path: /home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed
}
