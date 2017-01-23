import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase
import "dicthelper.js" as DictHelper

Rectangle {
    id: root

    property var experimentData
    property string imageSource
    property var modulesEventSource

    property var modules: {
        return {}
    }

//    function finishEditing(callback) {
//        for(var i in editors) {
//            var editor = editors[i]
//            if(editor.hasChanges) { // TODO this assumes only one editor has changes
//                editor.putChanges(function() {
//                    callback()
//                })
//                return
//            }
//        }
//        callback()
//    }

    function refreshAllModules() {
        modulesModel.clear()
        for(var id in modules) {
            if(!modules[id]) {
                continue
            }
            modulesModel.append({
                                    id: id,
                                    data: modules[id]
                                })
        }
        return
    }

    function refreshModules(path) {
        if(path === "/") {
            refreshAllModules()
            return
        }
        var pathSplit = path.split("/")
        for(var i = 0; i < modulesModel.count; i++) {
            var module = modulesModel.get(i)
            var id = pathSplit[1]
            if(module.id === id) {
                if(!modules[id]) {
                    modulesModel.remove(i)
                    return
                }
                modulesModel.set(i, {id: id, data: modules[id]})
                var dictEditor = moduleRepeater.itemAt(i)
                pathSplit.shift() // remove ""
                pathSplit.shift() // remove first element
                dictEditor.refreshPath(pathSplit)
                return
            }
        }
        refreshAllModules()
    }

    function putReceived(path, data) {
        DictHelper.put(modules, path, data)
        refreshModules(path)
    }

    function patchReceived(path, data) {
        DictHelper.patch(modules, path, data)
        refreshModules(path)
    }

    function errorReceived() {
        console.log("Got module error")
    }

    Component.onDestruction: {
        if(modulesEventSource) {
            modulesEventSource.close()
        }
    }

    color: "#fefefe"
    border {
        color: "#dedede"
        width: 1
    }

    EventSource {
        id: eventSource
        url: experimentData ? Firebase.server_url + "modules/" + experimentData.id + ".json?auth=" + Firebase.auth : ""
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

    Flickable {
        anchors.fill: parent
        visible: experimentData ? true : false
        contentHeight: container.height + 360
        ScrollBar.vertical: ScrollBar {}
        Column {
            id: container
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 48
            }

            spacing: 12

            Image {
                x: 140
                width: 64
                height: 64
                source: imageSource
                fillMode: Image.PreserveAspectCrop
            }

            ExperimentEdit {
                experimentData: root.experimentData
                property: "location"
                text: "Location"
            }

            ExperimentListEdit {
                experimentData: root.experimentData
                property: "users"
                text: "Experimenters"
            }

            ExperimentListEdit {
                experimentData: root.experimentData
                property: "subjects"
                autoCompletePath: "/subjects"
                text: "Subjects"
            }

            Text {
                width: 200
                font.pixelSize: 24
                font.weight: Font.Light
                color: "#434343"
                horizontalAlignment: Text.AlignRight
                text: "Modules"
            }

            Repeater {
                id: moduleRepeater
                model: ListModel {
                    id: modulesModel
                }
                DictionaryEditor {
                    x: 100
                    keyString: model.id
                    contents: model.data
                    basePath: "modules/" + experimentData.id + "/" + model.id
                    onContentsChanged: {
                        console.log("Contents changed", JSON.stringify(contents))
                    }
                }
            }

            Button {
                id: addModuleButton
                x: 100
                text: "Add module"
                onClicked: {
                    visible = false
                    newModuleColumn.visible = true
                }
            }

            Column {
                id: newModuleColumn
                x: 100
                visible: false
                spacing: 8

                ComboBox {
                    id: templateSelector
                    property var currentItem: currentIndex > -1 ? model.get(currentIndex) : {key: "", value: "", name: ""}
                    textRole: "key"
                    displayText: "Template: " + currentText
                    model: ListModel {
                        ListElement { key: "None"; value: "{}" }
                        ListElement { key: "Tracking"; name: "tracking"; value: '{"box_size": false, "wireless": false, "camera": false, "ttl_channel": false}' }
                        ListElement { key: "Grating"; name: "grating";value: '{"directions": false, "duration": false, "distance": false}' }
                    }
                    onActivated: {
                        nameField.text = model.get(index).name
                    }
                }

                Row {
                    spacing: 8
                    Label {
                        anchors.verticalCenter: nameField.verticalCenter
                        text: "Name: "
                    }

                    TextField {
                        id: nameField
                    }

                    Label {
                        anchors.verticalCenter: nameField.verticalCenter
                        color: "#ababab"
                        text: "(Permanent: Cannot be changed)"
                    }
                }

                Label {
                    text: templateSelector.currentItem.value
                }

                Button {
                    text: "Add"
                    onClicked: {
                        var selection = templateSelector.model.get(templateSelector.currentIndex)
                        var value = selection.value
                        var name = nameField.text
                        if(!value || !name) {
                            console.log("ERROR: Missing name or value")
                            return
                        }
                        var target = "modules/" + experimentData.id + "/" + name
                        var targetProperty = root.property
                        var data = JSON.parse(value)
                        Firebase.put(target, data, function(req) {
                            console.log("Add module result:", req.status, req.responseText)
                            templateSelector.currentIndex = 0
                            templateSelector.enabled = true
                            nameField.text = ""
                            nameField.enabled = true
                            addModuleButton.visible = true
                            newModuleColumn.visible = false
                        })
                        templateSelector.enabled = false
                        nameField.enabled = false
                    }
                }
            }
        }
    }
}
