import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "."

import "dicthelper.js" as DictHelper

Item {
    id: root

    property var currentTemplate: listView.currentItem ? listView.currentItem.contents : undefined

    EventSource {
        id: eventSource
        path: "templates"
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
            text: listView.count + " templates"
            color: "#787878"
            font.pixelSize: 14
        }
    }

    Rectangle {
        id: templateList
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
                        text: contents.name ? contents.name : ".."
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
                var template = {
                    registered: Date.now()
                }

                Firebase.post("templates", template, function(req) {
                    console.log("template created", req.responseText, req.statusText)
                })
            }
        }
    }

    Rectangle {
        id: templateView
        anchors {
            left: templateList.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        color: "#fdfdfd"
        Label {
            id: title
            anchors {
                left: parent.left
                top: parent.top
                margins: 96
            }
            font.pixelSize: 24
            font.weight: Font.Light
            text: currentTemplate.name
        }

        Column {
            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right
                margins: 48
            }
            Label {
                text: "Name:"
            }
            TextField {
                id: nameField
                onEditingFinished: {
                    if(nameField.text === currentTemplate.name) {
                        return
                    }
                    Firebase.put(currentTemplate.__path + "/name", nameField.text, function(req) {
                        console.log("Updated name", req.statusText, req.responseText)
                    })
                }

                Binding {
                    target: nameField
                    property: "text"
                    value: currentTemplate.name
                    when: currentTemplate !== undefined
                }
            }
        }
    }
}
