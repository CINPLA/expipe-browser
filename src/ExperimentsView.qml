import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase
import "dicthelper.js" as DictHelper

Item {
    id: root

    property string currentProject



    onCurrentProjectChanged: {
        experimentLoader.source = ""
    }

    ExperimentList {
        id: experimentList
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: 400
        currentProject: root.currentProject
    }

    Component {
        id: experimentComponent
        Experiment {
            experimentData: experimentList.currentData
        }
    }

    Loader {
        id: experimentLoader
        anchors {
            left: experimentList.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        sourceComponent: experimentList.currentIndex > -1 ? experimentComponent : undefined
    }
}
