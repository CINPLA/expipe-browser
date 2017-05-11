import QtQuick 2.4
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "."

import "md5.js" as MD5
import "dicthelper.js" as DictHelper

Rectangle {
    id: root
    property alias model: listView.model
    property alias currentIndex: listView.currentIndex
    property var experiments: {
        return {}
    }
    property string requestedId
    property string currentProject
    property var currentData
    property bool trigger: false
    property bool bindingEnabled: true

    onCurrentProjectChanged: {
        experiments = {}
    }

    color: "#efefef"
    border {
        color: "#dedede"
        width: 1
    }

    Binding {
        target: root
        property: "currentData"
        when: bindingEnabled
        value: {
            trigger
            return listView.currentItem ? listView.currentItem.modelData : undefined
        }
    }

    EventSource {
        id: eventSource
        path: "actions/" + currentProject
        includeHelpers: true
    }

    ActionProxy {
        id: actionProxy
        sourceModel: eventSource
        query: searchField.text
    }

    Rectangle {
        id: filtering
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width: 240
        color: "#ddd"

        Column {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8
            }

            Label {
                text: "Filter"
                font.pixelSize: 24
                font.weight: Font.Light
            }

            Label {
                text: "Action name:"
            }

            TextField {
                id: searchField
                anchors {
                    left: parent.left
                    right: parent.right
                }

                placeholderText: "Search"
            }

            TableView {
                id: tagListView

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 175
                model: ActionAttributeModel {
                    source: eventSource
                    name: 'tags'
                }
                selectionMode: SelectionMode.MultiSelection
                selection.onSelectionChanged: {
                    var tags = ""
                    selection.forEach(function(rowIndex) {
                        tags = tags + ";" + model.get(rowIndex)
                    })
                    actionProxy.setRequirement("tags", tags)
                }
                TableViewColumn {
                    role: "attribute"
                    title: "Tag"
                    width: 100
                }
                // delegate: Item {
                //     anchors {
                //         left: parent.left
                //         right: parent.right
                //     }
                //     height: 40
                //     Text {
                //         text: tag
                //         anchors {
                //             left: parent.left
                //             leftMargin: 8
                //             verticalCenter: parent.verticalCenter
                //         }
                //     }
                //     MouseArea {
                //         anchors.fill: parent
                //         onClicked: tagListView.
                //     }
                // }
            }
            TableView {
                id: subjectListView

                anchors {
                    left: parent.left
                    right: parent.right
                    top: tagListView.bottom
                }
                height: 175
                model: ActionAttributeModel {
                    source: eventSource
                    name: 'subjects'
                }
                selectionMode: SelectionMode.MultiSelection
                selection.onSelectionChanged: {
                    var tags = ""
                    selection.forEach(function(rowIndex) {
                        tags = tags + ";" + model.get(rowIndex)
                    })
                    actionProxy.setRequirement("subjects", tags)
                }
                TableViewColumn {
                    role: "attribute"
                    title: "Subject"
                    width: 100
                }
                TableView {
                    id: typeListView

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: subjectListView.bottom
                    }
                    height: 175
                    model: ActionAttributeModel {
                        source: eventSource
                        name: 'type'
                    }
                    selectionMode: SelectionMode.MultiSelection
                    selection.onSelectionChanged: {
                        var tags = ""
                        selection.forEach(function(rowIndex) {
                            tags = tags + ";" + model.get(rowIndex)
                        })
                        actionProxy.setRequirement("type", tags)
                    }
                    TableViewColumn {
                        role: "attribute"
                        title: "Action type"
                        width: 100
                    }
                }
                TableView {
                    id: locationListView

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: typeListView.bottom
                    }
                    height: 175
                    model: ActionAttributeModel {
                        source: eventSource
                        name: 'location'
                    }
                    selectionMode: SelectionMode.MultiSelection
                    selection.onSelectionChanged: {
                        var tags = ""
                        selection.forEach(function(rowIndex) {
                            tags = tags + ";" + model.get(rowIndex)
                        })
                        actionProxy.setRequirement("location", tags)
                    }
                    TableViewColumn {
                        role: "attribute"
                        title: "Location"
                        width: 100
                    }
                }
                TableView {
                    id: userListView

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: locationListView.bottom
                    }
                    height: 175
                    model: ActionAttributeModel {
                        source: eventSource
                        name: 'users'
                    }
                    selectionMode: SelectionMode.MultiSelection
                    selection.onSelectionChanged: {
                        var tags = ""
                        selection.forEach(function(rowIndex) {
                            tags = tags + ";" + model.get(rowIndex)
                        })
                        actionProxy.setRequirement("users", tags)
                    }
                    TableViewColumn {
                        role: "attribute"
                        title: "User"
                        width: 100
                    }
                }
                TableView {
                    id: datetimeListView

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: userListView.bottom
                    }
                    height: 175
                    model: ActionAttributeModel {
                        source: eventSource
                        name: 'datetime'
                    }
                    selectionMode: SelectionMode.MultiSelection
                    selection.onSelectionChanged: {
                        var tags = ""
                        selection.forEach(function(rowIndex) {
                            tags = tags + ";" + model.get(rowIndex)
                        })
                        actionProxy.setRequirement("datetime", tags)
                    }
                    TableViewColumn {
                        role: "attribute"
                        title: "datetime"
                        width: 100
                    }
                }
            }
        }
    }

    Rectangle {
        id: stuff
        anchors {
            left: filtering.right
            right: parent.right
            top: parent.top
        }
        color: "#cecece"

        Text {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 16
            }
            color: "#787878"

            text: listView.count + " actions"
        }
    }

    QQC1.ScrollView {
        anchors {
            top: stuff.bottom
            bottom: parent.bottom
            right: parent.right
            left: filtering.right
        }
        ListView {
            id: listView
            anchors.fill: parent
            clip: true
            model: actionProxy

            highlightMoveDuration: 0
            highlight: Rectangle {
                color: "black"
                opacity: 0.1
            }
            delegate: Rectangle {
                readonly property var index: model.index
                readonly property var key: model.key
                readonly property var modelData: model.contents
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 64

                Item {
                    id: imageItem
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: height
                    Identicon {
                        anchors.centerIn: parent
                        width: parent.height * 0.6
                        height: width
                        action: modelData
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
                        text: key
                        font.pixelSize: 12
                    }
                    Text {
                        color: "#545454"
                        text: {
                            var results = []
                            if(modelData.type) {
                                results.push(modelData.type)
                            }
                            if(modelData.datetime) {
                                try {
                                    var date = new Date(modelData.datetime)
                                    var dateString = date.toISOString().substring(0, 10)
                                    results.push(dateString)
                                } catch (e) {
                                }

                            }
                            return results.join(", ")
                        }
                        font.pixelSize: 11
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                        forceActiveFocus()
                    }
                }
            }
        }
    }

    Button {
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 32
        }
        // highlighted: true
        text: "Create new"
        onClicked: {
            newDialog.open()
        }
    }

    Dialog {
        id: newDialog
        title: "Create new action"
        Column {
            spacing: 8
            Label {
                text: "Provide an unique ID for your action.\n" +
                      "A good ID is easy to remember and follows a naming scheme."
            }
            TextField {
                id: newName
                selectByMouse: true
                text: {
                    return new Date().toISOString().slice(0, 10)
                }
            }
            Label {
                text: "Examples: '2016-01-12_1', 'bobby_1_init', 'lucia_surgery'"
            }
        }
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAccepted: {
            if(!currentProject) {
                console.log("ERROR: Current project not set.")
                return
            }

            if(!newName.text) {
                console.log("ERROR: Name cannot be empty.")
                return
            }
            var registered = (new Date()).toISOString()
            var experiment = {
                registered: registered
            }
            Firebase.put("actions/" + currentProject + "/" + newName.text, experiment, function(req) {
                var experiment = JSON.parse(req.responseText)
                requestedId = experiment.name
            })
        }
    }
}
