#!/bin/bash
pyrcc5 -o expipebrowser/qml_qrc.py expipebrowser/qml.qrc
python setup.py install
