#!/bin/bash
# pip install pyqt5
which pyrcc5
pyrcc5 -o expipebrowser/qml_qrc.py expipebrowser/qml.qrc
python setup.py install
