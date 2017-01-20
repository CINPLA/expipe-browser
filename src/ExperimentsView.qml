import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase

Item {
    id: root

    function refresh() {
        var url = Firebase.url + "experiments.json"
        var req = new XMLHttpRequest()
        req.open("GET", url)
        req.onreadystatechange = function() {
            if(req.readyState != XMLHttpRequest.DONE) {
                return
            }
            console.log(req.responseText)
            var experiments = JSON.parse(req.responseText)
            listModel.clear()
            for(var id in experiments) {
                var experiment = experiments[id]
                experiment.experiment_id = id
                listModel.append(experiment)
            }
        }
        req.send()
    }
    
    ExperimentList {
        id: experimentList
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        Component.onCompleted: {
            refresh()
        }
        model: ListModel {
            id: listModel
        }
        width: 400
    }

    
    Experiment {
        anchors {
            left: experimentList.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        experimentData: experimentList.currentData
        imageSource: experimentList.currentImageSource
    }

    Button {
        text: "Create something"
        onClicked: {
            var url = Firebase.url + "experiments.json"
            var req = new XMLHttpRequest()
            req.onreadystatechange = function() {
                if(req.readyState != XMLHttpRequest.DONE) {
                    return
                }
                console.log("Put result:", req.status, req.responseText)
                refresh()
            }
            req.open("POST", url)
            var experiment = {"datetime":"2016-11","experimenter":"ida","filename":"blah.exdir","project":"ida_tracking","registered":"2017-01-03","subject":"b_1515","tracking":{"box_size":"small","camera":"cheap"}}
            req.send(JSON.stringify(experiment))
        }
    }
}
