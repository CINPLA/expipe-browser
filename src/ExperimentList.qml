import QtQuick 2.4
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

//import ExpipeBrowser 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase
import "imagehash.js" as ImageHash

Rectangle {
    id: root
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex
    readonly property var currentData: listView.currentItem ? listView.currentItem.modelData : undefined
    
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
                        smooth: true
                        source: {
                            return ImageHash.get(modelData.id, 64)
                        }
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
                        text: model.id
                        font.pixelSize: 12
                    }
                    Text {
                        color: "#545454"
                        text: {
                            var results = []
                            if(model.type) {
                                results.push(model.type)
                            }
                            if(model.datetime) {
                                var date = new Date(model.datetime)
                                results.push(date.toISOString().substring(0, 10))
                            }
                            return results.join(", ")
                        }
                        font.pixelSize: 11
                    }
                }
                onClicked: {
                    listView.currentIndex = index
                }
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
