import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "."

import "dicthelper.js" as DictHelper

Item {
    id: root

    readonly property string currentProject: listView.currentIndex > -1 ? listView.currentItem.key : ""
    property var projectsModel: []
    property var projects: {
        return {}
    }

    function updateModel() {
        // TODO update surgically
        var newModel = []
        for(var id in projects) {
            newModel.push({id: id, data: data})
        }
        projectsModel = newModel
    }

    EventSource {
        id: eventSource
        path: "projects"
        includeHelpers: true
    }

    Rectangle {
        id: stuff
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 36
        color: "#cecece"

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 20
            }
            text: projectsModel.length + " projects"
            color: "#787878"
            font.pixelSize: 14
        }
    }

    Rectangle {
        id: projectList
        anchors {
            left: parent.left
            top: stuff.bottom
            bottom: parent.bottom
        }
        width: 400

        color: "#efefef"
        border {
            color: "#dedede"
            width: 1
        }

        ListView {
            id: listView
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: parent.left
            }
            ScrollBar.vertical: ScrollBar {}
            model: eventSource
            delegate: Item {
                readonly property var key: model.key
                readonly property var contents: model.contents
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 64

                Row {
                    anchors {
                        margins: 12
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: 10
                    Identicon {
                        width: height
                        height: parent.height
                        project: key
                    }
                    Text {
                        color: "#121212"
                        text: key
//                        font.pixelSize: 14
                    }
                    Text {
                        color: "#121212"
                        text: contents.registered ? contents.registered : ".."
//                        font.pixelSize: 14
                    }
                    Text {
                        color: "#121212"
                        text: contents.start_date ? contents.start_date : ".."
//                        font.pixelSize: 14
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                    }
                }
            }
            highlightMoveDuration: 400
            highlight: Rectangle {
                color: "black"
                opacity: 0.1
            }
            clip: true
        }

        Button {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 32
            }
            highlighted: true
            text: "Create new"
            onClicked: {
                newDialog.open()
            }
        }
    }

    Dialog {
        id: newDialog
        title: "Create new project"
        Column {
            spacing: 8
            Label {
                text: "Provide an unique ID for your project.\n" +
                      "This is permanent and cannot be changed later."
            }
            TextField {
                id: newName
            }
            Label {
                text: "Examples: 'mikkel_opto', 'perineural_v2_elimination'"
            }
        }
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAccepted: {
            if(!newName.text) {
                console.log("ERROR: Name cannot be empty.")
                return
            }
            var registered = (new Date()).toISOString()
            var project = {
                registered: registered
            }
            Firebase.put("projects/" + newName.text, project, function(req) {
                console.log("Project created", req.responseText, req.statusText)
            })
        }
    }

    Rectangle {
        id: projectView
        anchors {
            left: projectList.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        color: "#fdfdfd"
        Label {
            anchors {
                left: parent.left
                top: parent.top
                margins: 96
            }
            font.pixelSize: 24
            font.weight: Font.Light
            text: currentProject
        }

        Label {
            anchors.centerIn: parent
            text: "Projects cannot be edited yet"
        }
    }
}
