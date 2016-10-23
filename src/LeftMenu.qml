import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5

Rectangle {
    id: leftMenu

    property string selectedState: menuView.currentItem ? menuView.currentItem.identifier : "experiments"
    
    color: "#363636"
    
    ListModel {
        id: menuModel
        ListElement {
            name: "Experiments"
            identifier: "experiments"
        }
        ListElement {
            name: "Users"
            identifier: "users"
        }
        ListElement {
            name: "Projects"
            identifier: "projects"
        }
        ListElement {
            name: "Analyses"
            identifier: "users"
        }
    }
    
    TextField {
        id: searchField
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 20
        }
        placeholderText: "Search"
    }
    
    ListView {
        id: menuView
        anchors {
            top: searchField.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: 24
            //                    margins: 20
        }
        model: menuModel
        delegate: Item {
            property string identifier: model.identifier
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 36
            Text {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    leftMargin: 24
                    rightMargin: 24
                }
                
                color: "white"
                text: name
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuView.currentIndex = index
                }
            }
        }
        highlight: Rectangle {
            color: "white"
            opacity: 0.1
        }
        clip: true
    }
}
