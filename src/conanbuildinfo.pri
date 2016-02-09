CONAN_INCLUDEPATH += /home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include \
    /home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include
CONAN_LIBS += -L/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib \
    -L/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib
CONAN_BINDIRS += /home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin \
    /home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin
CONAN_LIBS += -lelegant_hdf5
CONAN_DEFINES += 
CONAN_QMAKE_CXXFLAGS += 
CONAN_QMAKE_CFLAGS += 
CONAN_QMAKE_LFLAGS += 
CONAN_QMAKE_LFLAGS += 

CONAN_INCLUDEPATH_CATCH += /home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include
CONAN_LIBS_CATCH += -L/home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib
CONAN_BINDIRS_CATCH += /home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin
CONAN_LIBS_CATCH += 
CONAN_DEFINES_CATCH += 
CONAN_QMAKE_CXXFLAGS_CATCH += 
CONAN_QMAKE_CFLAGS_CATCH += 
CONAN_QMAKE_LFLAGS_CATCH += 
CONAN_QMAKE_LFLAGS_CATCH += 
CONAN_ROOTPATH_CATCH = /home/svenni/.conan/data/Catch/1.3.2/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed

CONAN_INCLUDEPATH_H5CPP += /home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/include
CONAN_LIBS_H5CPP += -L/home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/lib
CONAN_BINDIRS_H5CPP += /home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed/bin
CONAN_LIBS_H5CPP += -lelegant_hdf5
CONAN_DEFINES_H5CPP += 
CONAN_QMAKE_CXXFLAGS_H5CPP += 
CONAN_QMAKE_CFLAGS_H5CPP += 
CONAN_QMAKE_LFLAGS_H5CPP += 
CONAN_QMAKE_LFLAGS_H5CPP += 
CONAN_ROOTPATH_H5CPP = /home/svenni/.conan/data/h5cpp/0.1/dragly/master/package/0692fb2bd888ba708ca65670557c56d2e16851ed

CONFIG(conan_basic_setup) {
    INCLUDEPATH += $$CONAN_INCLUDEPATH
    LIBS += $$CONAN_LIBS
    BINDIRS += $$CONAN_BINDIRS
    LIBS += $$CONAN_LIBS
    DEFINES += $$CONAN_DEFINES
    QMAKE_CXXFLAGS += $$CONAN_QMAKE_CXXFLAGS
    QMAKE_CFLAGS += $$CONAN_conan_basic_setupQMAKE_CFLAGS
    QMAKE_LFLAGS += $$CONAN_QMAKE_LFLAGS
}
