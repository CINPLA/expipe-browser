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

    property string currentProject
    property string requestedId

    property var experiments: {
        return {}
    }

    function refresh() {
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
                    experimentList.currentIndex = i
                    break
                }
            }
        }
//        if(experimentList.currentIndex > -1) {
//            if(root.experiment) {
//                root.experiment.experimentData = listModel.get(experimentList.currentIndex)
//            }
//        }
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
//                if(experimentList.currentIndex === i) {
//                    if(root.experiment) {
//                        root.experiment.experimentData = listModel.get(experimentList.currentIndex)
//                    }
//                }
                return
            }
        }
        refresh()
    }

    function errorReceived() {
        console.log("View received error")
    }

    function retryConnection() {
        console.log("Retrying connection", currentProject)
        if(currentProject) {

        }
    }

    onCurrentProjectChanged: {
        experiments = {}
        listModel.clear()
        loader.sourceComponent = undefined
        loader.sourceComponent = component
    }

    ListModel {
        id: listModel
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: component
        Item {
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

            ExperimentList {
                id: experimentList
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                model: listModel
                width: 400

                onCurrentIndexChanged: {
                    loader.source = ""
                    if(experimentList.currentIndex > -1) {
                        experimentLoader.source = "Experiment.qml"
                        experimentLoader.item.experimentData = listModel.get(experimentList.currentIndex)
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
            }

            Loader {
                id: experimentLoader
                anchors {
                    left: experimentList.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
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
    }
}
