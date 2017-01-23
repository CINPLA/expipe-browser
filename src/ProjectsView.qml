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

    readonly property string currentProject: listView.currentIndex > -1 ? projectsModel[listView.currentIndex].id : ""
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

    function retryConnection() {
        eventSource.url = Firebase.server_url + "projects.json?auth=" + Firebase.auth
    }

    EventSource {
        id: eventSource
        onEventReceived: {
            var d = JSON.parse(data)
            switch(type) {
            case "put":
                DictHelper.put(projects, d.path, d.data)
                updateModel()
                break
            case "patch":
                DictHelper.patch(projects, d.path, d.data)
                updateModel()
                break
            default:
                console.log("Event", type, "data", data)
            }
        }
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
            text: "Current project:"
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
            model: projectsModel
            delegate: Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 64

                Column {
                    spacing: 10
                    anchors {
                        margins: 12
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    Text {
                        color: "#545454"
                        text: modelData.id
                        font.pixelSize: 14
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
    }
}
