import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase

Item {
    id: root

    property var experiments: {
        return {}
    }

    function refresh() {
        var previousId
        if(experimentList.currentData) {
            previousId = experimentList.currentData.id
        }
        listModel.clear()
        for(var id in experiments) {
            var experiment = experiments[id]
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
    }

    function refreshOne(id) {
        for(var i = 0; i < listModel.count; i++) {
            var item = listModel.get(i)
            if(item.id === id) {
                if(experiments[id]) {
                    listModel.set(i, experiments[id])
                } else {
                    listModel.remove(i)
                }

                return
            }
        }
        refresh()
    }

    function putReceived(path, data) {
        console.log("Got put on", path)
        if(path === "/") {
            experiments = data
            console.log("Result", JSON.stringify(experiments))
            refresh()
            return
        }
        var parts = path.split("/")
        var target = experiments
        for(var i = 0; i < parts.length - 1; i++) {
            if(parts[i] === "") {
                continue
            }
            target = target[parts[i]]
        }
        console.log("Target", target, parts[i], data)
        target[parts[i]] = data
        console.log("Result", JSON.stringify(experiments))
        refreshOne(parts[1])
    }

    function patchReceived(path, data) {
        console.log("Got patch on", path)
        if(path === "/") {
            experiments = data
            console.log("Result", JSON.stringify(experiments))
            refresh()
            return
        }
        var parts = path.split("/")
        var target = experiments
        for(var i = 0; i < parts.length - 1; i++) {
            if(parts[i] === "") {
                continue
            }
            target = target[parts[i]]
        }
        for(var j in data) {
            console.log("Patching", "[", parts[i], "][", j, "] =", data[j])
            target[parts[i]][j] = data[j]
        }
        console.log("Result", JSON.stringify(experiments))
        refreshOne(parts[1])
    }

    function errorReceived() {
        console.log("View received error")
    }

    function retryConnection() {
        console.log("Retrying connection")
        Firebase.listen(root, "experiments", putReceived, patchReceived, errorReceived)
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
            experiment.finishEditing(function() {
                experiment.experimentData = currentData
            })
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
                var experiment = {"datetime":"","experimenter":"","filename":"","project":"","registered":"","subject":""}
                Firebase.post("experiments", experiment, function() {
                    console.log("Posted!")
                })
            }
        }
    }
    
    Experiment {
        id: experiment
        anchors {
            left: experimentList.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
//        experimentData: experimentList.currentData
        imageSource: experimentList.currentImageSource
    }
}
