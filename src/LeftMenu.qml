import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

//import ExpipeBrowser 1.0

import "md5.js" as MD5

Rectangle {
    id: leftMenu

    property string selectedState: menuView.currentItem ? menuView.currentItem.identifier : "experiments"
    property string currentProject: "None selected"
    
    color: "#363636"
    
    ListModel {
        id: menuModel
        ListElement {
            name: "Projects"
            identifier: "projects"
        }
        ListElement {
            name: "Actions"
            identifier: "actions"
            needsProject: true
        }
        ListElement {
            name: "Subjects"
            identifier: "subjects"
            needsProject: true
        }
        ListElement {
            name: "Users"
            identifier: "users"
            needsProject: true
        }
        ListElement {
            name: "Templates"
            identifier: "templates"
        }
    }
    
    Column {
        id: menuView
        property int currentIndex: 0
        property var currentItem: repeater.itemAt(currentIndex)
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        Repeater {
            id: repeater
            model: menuModel
            delegate: Item {
                property string identifier: model.identifier
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 36
                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    opacity: 0.1
                    visible: index === menuView.currentIndex
                }
                Text {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        leftMargin: 24
                        rightMargin: 24
                    }

                    color: itemArea.enabled ? "white" : "#ababab"
                    text: name
                }
                MouseArea {
                    id: itemArea
                    enabled: currentProject != "" || !needsProject
                    anchors.fill: parent
                    onClicked: {
                        menuView.currentIndex = index
                    }
                }
            }
            clip: true
        }
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 20
            bottomMargin: 48
        }
        spacing: 8
        Label {
            anchors {
                left: parent.left
                right: parent.right
            }

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#ababab"
            text: "Project:"
        }
        Label {
            anchors {
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#dedede"
            text: currentProject
        }
    }
}
