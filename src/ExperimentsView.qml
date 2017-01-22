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

    property string requestedId
    property var experiment: loader.item

    property var experiments: {
        return {}
    }

    function refresh() {
        console.log("Refreshing", requestedId)
        var previousId
        if(requestedId !== "") {
            previousId = requestedId
        } else if(experimentList.currentData) {
            previousId = experimentList.currentData.id
        }
        listModel.clear()
        for(var id in experiments) {
            var experiment = experiments[id]
            if(!experiment) {
                continue
            }
            experiment.id = id
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
        if(experimentList.currentIndex > -1) {
            if(root.experiment) {
                root.experiment.experimentData = listModel.get(experimentList.currentIndex)
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
                if(experimentList.currentIndex === i) {
                    if(root.experiment) {
                        root.experiment.experimentData = listModel.get(experimentList.currentIndex)
                    }
                }
                return
            }
        }
        refresh()
    }

    function putReceived(path, data) {
        DictHelper.put(experiments, path, data)
        console.log("Experiments", JSON.stringify(experiments))
        if(path === "/") {
            refresh()
        } else {
            refreshOne(path.split("/")[1])
        }
    }

    function patchReceived(path, data) {
        DictHelper.patch(experiments, path, data)
        console.log("Got patch on", path)
        if(path === "/") {
            refresh()
        } else {
            refreshOne(path.split("/")[1])
        }
    }

    function errorReceived() {
        console.log("View received error")
    }

    function retryConnection() {
        console.log("Retrying connection")
//        Firebase.listen(root, "actions", putReceived, patchReceived, errorReceived)
        eventSource.url = Firebase.server_url + "actions.json?auth=" + Firebase.auth
    }

    EventSource {
        id: eventSource
        onEventReceived: {
            console.log("Received event", type, data)
            var d = JSON.parse(data)
            if(type == "put") {
                putReceived(d.path, d.data)
            } else if(type == "patch") {
                patchReceived(d.path, d.data)
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
        model: ListModel {
            id: listModel
        }
        width: 400

        onCurrentDataChanged: {
            root.experiment.finishEditing(function() { // TODO do this differently? onDestruction?
                root.experiment.experimentData = listModel.get(experimentList.currentIndex)
            })
        }

        onCurrentIndexChanged: {
            loader.source = ""
            if(experimentList.currentIndex > -1) {
                loader.source = "Experiment.qml"
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
                var datetime = (new Date()).toISOString()
                var experiment = {
                    registered: datetime
                }
                Firebase.post("actions", experiment, function(req) {
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
    
    Loader {
        id: loader
        anchors {
            left: experimentList.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }
}
