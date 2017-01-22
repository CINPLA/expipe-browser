import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase

Rectangle {
    id: root

    property var experimentData
    property string imageSource

    property var editors: [
//        experimenter,
        project,
    ]

    property var modules

    function finishEditing(callback) {
        for(var i in editors) {
            var editor = editors[i]
            if(editor.hasChanges) { // TODO this assumes only one editor has changes
                editor.putChanges(function() {
                    callback()
                })
                return
            }
        }
        callback()
    }

    function putReceived() {
        console.log("Got module put")
    }

    function patchReceived() {
        console.log("Got module patch")
    }

    function errorReceived() {
        console.log("Got module error")
        // TODO reset listening on error
    }

    onExperimentDataChanged: {
        console.log("Experiment has change")
        if(experimentData.id) {
//            Firebase.listen(root, "modules/" + experimentData.id, putReceived, patchReceived, errorReceived)
        }
    }

    color: "#fefefe"
    border {
        color: "#dedede"
        width: 1
    }

    Flickable {
        anchors.fill: parent
        visible: experimentData ? true : false
        contentHeight: container.height + 360
        ScrollBar.vertical: ScrollBar {}
        Column {
            id: container
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 48
            }

            spacing: 12

            Image {
                x: 140
                width: 64
                height: 64
                source: imageSource
                fillMode: Image.PreserveAspectCrop
            }

//            ExperimentEdit {
//                id: experimenter
//                experimentData: root.experimentData
//                property: "users"
//                text: "Users"
//            }

            ExperimentEdit {
                id: project
                experimentData: root.experimentData
                property: "project"
                text: "Project"
            }

            ExperimentListEdit {
                experimentData: root.experimentData
                property: "users"
                text: "Experimenters"
            }

            ExperimentListEdit {
                experimentData: root.experimentData
                property: "subjects"
                autoCompletePath: "/subjects"
                text: "Subjects"
            }

        }
    }
}
