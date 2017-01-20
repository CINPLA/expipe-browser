import QtQuick 2.4
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5

Rectangle {
    id: root
    property alias model: listView.model
    readonly property var currentData: listView.currentItem ? listView.currentItem.modelData : undefined
    readonly property string currentImageSource: listView.currentItem ? listView.currentItem.imageSource : ""
    
    color: "#efefef"
    border {
        color: "#dedede"
        width: 1
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
            text: listView.count + " experiments"
            color: "#787878"
            font.pixelSize: 14
        }
    }
    
    QQC1.ScrollView {
        anchors {
            top: stuff.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }
        ListView {
            id: listView
            anchors.fill: parent
            delegate: ItemDelegate {
                property variant modelData: model
                property string imageSource: "http://gravatar.com/avatar/" + MD5.md5("s@dragly.com")
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 64

                Component.onCompleted: {

                }

                Item {
                    id: imageItem
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: height
                    Image {
                        anchors.centerIn: parent
                        width: parent.height * 0.6
                        height: width
                        fillMode: Image.PreserveAspectCrop
                        source: imageSource
                    }
                }

                Column {
                    spacing: 10
                    anchors {
                        topMargin: 12
                        left: imageItem.right
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    Text {
                        color: "#121212"
                        text: model.project + ", rat " + model.subject
                        font.pixelSize: 12
                    }
                    Text {
                        color: "#545454"
                        text: model.registered
                        font.pixelSize: 11
                    }
                }
//                MouseArea {
//                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                    }
//                }
            }
            highlightMoveDuration: 0
            highlight: Rectangle {
                color: "black"
                opacity: 0.1
            }
            clip: true
        }
    }
}
