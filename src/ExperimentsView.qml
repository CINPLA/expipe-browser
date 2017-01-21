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
        listModel.clear()
        for(var id in experiments) {
            var experiment = experiments[id]
            experiment.id = id
            listModel.append(experiment)
        }
    }

    function refreshOne(id) {
        for(var i = 0; i < listModel.count; i++) {
            var item = listModel.get(i)
            if(item.id === id) {
                listModel.set(i, experiments[id])
                console.log("Set listmodel")
            }
        }
    }

    function putReceived(path, data) {
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
                var url = Firebase.server_url + "experiments.json"
                var req = new XMLHttpRequest()
                req.onreadystatechange = function() {
                    if(req.readyState != XMLHttpRequest.DONE) {
                        return
                    }
                    if(req.status != 200) {
                        console.log("ERROR:", req.status, req.statusText)
                        console.log(req.responseText)
                        return
                    }
                    console.log("Put result:", req.status, req.responseText)
                    refresh()
                }
                req.open("POST", url)
                var experiment = {"datetime":"2016-11","experimenter":"mikkel","filename":"blah.exdir","project":"ida_tracking","registered":"2017-01-03","subject":"b_1515","tracking":{"box_size":"small","camera":"cheap"}}
                req.setRequestHeader("Authorization", Firebase.authorization)
                req.send(JSON.stringify(experiment))
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
