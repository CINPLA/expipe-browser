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
    property var currentData: {
        trigger // hack to trigger change on deep changes in listModel
        return listModel.get(currentIndex)
    }
    property bool trigger

    onCurrentProjectChanged: {
        experiments = {}
        listModel.clear()
    }
    
    color: "#efefef"
    border {
        color: "#dedede"
        width: 1
    }

    function refresh() {
        trigger = !trigger
        console.log("Refreshing", requestedId)
        var previousId
        //        if(requestedId !== "") {
        //            previousId = requestedId
        //        } else if(experimentList.currentData) {
        //            previousId = experimentList.currentData.id
        //        }
        listModel.clear()
        for(var id in experiments) {
            var experiment = experiments[id]
            if(!experiment) {
                continue
            }
            experiment.id = id
            experiment.project = currentProject
            listModel.append(experiment)
        }

        // set the correct index back
        if(previousId) {
            for(var i = 0; i < listModel.count; i++) {
                if(listModel.get(i).id === previousId) {
                    currentIndex = i
                    break
                }
            }
        }
    }

    function refreshOne(id) {
        for(var i = 0; i < listModel.count; i++) {
            var item = listModel.get(i)
            if(item.id === id) {
                if(experiments[id]) {
                    console.log("Refreshing", i, id)
                    listModel.set(i, experiments[id])
                } else {
                    listModel.remove(i)
                }
                trigger = !trigger
                return
            }
        }
        refresh()
    }

    function errorReceived() {
        console.log("View received error")
    }

    ListModel {
        id: listModel
    }


    EventSource {
        id: eventSource
        url: Firebase.server_url + "actions/" + currentProject + "/.json?auth=" + Firebase.auth
        onEventReceived: {
            console.log("Received event", type, data)
            var d = JSON.parse(data)
            switch(type) {
            case "put":
                DictHelper.put(experiments, d.path, d.data)
                console.log("Experiments", JSON.stringify(experiments))
                if(d.path === "/") {
                    refresh()
                } else {
                    refreshOne(d.path.split("/")[1])
                }
                break
            case "patch":
                DictHelper.patch(experiments, d.path, d.data)
                console.log("Got patch on", d.path)
                if(d.path === "/") {
                    refresh()
                } else {
                    refreshOne(d.path.split("/")[1])
                }
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
        color: "#cecece"
        height: stuffColumn.height + 16

        Column {
            id: stuffColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 16
            }

            TextField {
                onTextChanged: {

                }
            }
        
            Text {
                text: listView.count + " actions"
                color: "#787878"
                font.pixelSize: 14
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
            model: listModel
            highlightMoveDuration: 0
            highlight: Rectangle {
                color: "black"
                opacity: 0.1
            }
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
