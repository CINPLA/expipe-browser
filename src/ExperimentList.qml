import QtQuick 2.4
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase
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
    property var currentData: listView.currentItem.modelData
    property bool trigger: false
    property bool bindingEnabled: true

//    Binding {
//        target: root
//        property: "currentData"
//        when: listView.currentItem && bindingEnabled
//        value: {
//            trigger
//            return experiments[listView.currentItem.key]
//        }
//    }

    onCurrentProjectChanged: {
        experiments = {}
        listModel.clear() // TODO, see if this is needed
        searchModel.clear()
//        refresh()
    }
    
    color: "#efefef"
    border {
        color: "#dedede"
        width: 1
    }

//    function refresh() {
//        listModel.clear()
//        for(var id in experiments) {
//            var experiment = experiments[id]
//            if(!experiment) {
//                continue
//            }
//            experiment.id = id
//            experiment.project = currentProject
//            listModel.append(experiment)
//        }
//        refreshSearchModel()
//    }

//    function refreshOne(id) {
//        for(var i = 0; i < listModel.count; i++) {
//            var item = listModel.get(i)
//            if(item.id === id) {
//                if(experiments[id]) {
//                    console.log("Refreshing", i, id)
//                    listModel.set(i, experiments[id])
//                } else {
//                    listModel.remove(i)
//                }
//                trigger = !trigger
//                return
//            }
//        }
//        refresh()
//    }

//    function refreshSearchModel() {
//        bindingEnabled = false
//        var previousId
//        if(currentData) {
//            previousId = currentData.id
//        }
//        searchModel.clear()
//        for(var i = 0; i < listModel.count; i++) {
//            var experiment = listModel.get(i)
//            var found = true
//            var needle = searchField.text
//            if(needle !== "") {
//                var haystack = JSON.stringify(experiment)
//                if(haystack.indexOf(needle) > -1) {
//                    found = true
//                } else {
//                    found = false
//                }
//            }
//            if(found) {
//                searchModel.append({key: experiment.id})
//            }
//        }
//        for(var i = 0; i < searchModel.count; i++) {
//            if(searchModel.get(i).key === previousId) {
//                currentIndex = i
//            }
//        }
//        bindingEnabled = true
//    }

//    ListModel {
//        id: listModel
//    }

//    ListModel {
//        id: searchModel
//    }

    EventSource {
        id: eventSource
        path: "actions/" + currentProject
    }
    
    Rectangle {
        id: stuff
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        color: "#cecece"
        height: searchField.height + 24

        Text {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 16
            }
            color: "#787878"

            text: listView.count + " actions"
        }

        TextField {
            id: searchField
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 16
            }

            placeholderText: "Search"

            onTextChanged: {
                refreshSearchModel()
            }
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
            clip: true
            model: eventSource

            highlightMoveDuration: 0
            highlight: Rectangle {
                color: "black"
                opacity: 0.1
            }
            delegate: ItemDelegate {
                readonly property var key: model.key
                readonly property var modelData: model.contents
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
                    Identicon {
                        anchors.centerIn: parent
                        width: parent.height * 0.6
                        height: width
                        action: contents
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
                                var date = new Date(modelData.datetime)
                                results.push(date.toISOString().substring(0, 10))
                            }
                            return results.join(", ")
                        }
                        font.pixelSize: 11
                    }
                }
                onClicked: {
                    listView.currentIndex = index
                    forceActiveFocus()
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
        highlighted: true
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
                for(var i = 0; i < listModel.count; i++) {
                    if(listModel.get(i).id === experiment.name) {
                        experimentList.currentIndex = i
                        return
                    }
                }
                requestedId = experiment.name
            })
        }
    }
}
