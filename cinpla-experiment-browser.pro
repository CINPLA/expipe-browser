TEMPLATE = subdirs
SUBDIRS += libs src
CONFIG += ordered
src.depends = libs
