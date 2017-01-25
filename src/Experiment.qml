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

    property var modules: {
        return {}
    }

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
        modulesLoadingText.visible = false
    }

    function refreshModules(path) {
        console.log("PATH IS", path)
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

    color: "#fdfdfd"
    border {
        color: "#dedede"
        width: 1
    }

    EventSource {
        url: experimentData ? Firebase.server_url + "modules/" + experimentData.project + "/" + experimentData.id + ".json?auth=" + Firebase.auth : ""
        onUrlChanged: {
            modulesModel.clear()
            modulesLoadingText.visible = true
        }

        onEventReceived: {
            var d = JSON.parse(data)
            if(type == "put") {
                putReceived(d.path, d.data)
            } else if(type == "patch") {
                patchReceived(d.path, d.data)
            }
        }
    }

    Clipboard {
        id: clipboard
    }

    Flickable {
        anchors.fill: parent
        contentHeight: container.height + 360
        ScrollBar.vertical: ScrollBar {}

        Button {
            id: codeButton
            property string snippet: "from expipe.io import find_action\n" +
                                     "action = expipe.io.get_action(project='" + experimentData.project + "', action='" + experimentData.id + "')\n" +
                                     "# continue working with action"
            anchors {
                right: parent.right
                top: parent.top
                rightMargin: 48
                topMargin: 96
            }
            text: "Copy Python code"
            onClicked: {
                clipboard.setText(snippet)
                codePopup.open()
            }
        }

        Column {
            id: container
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 96
            }

            spacing: 12

            Row {
                x: 140
                spacing: 20

                Identicon {
                    id: image
                    width: 64
                    height: 64
                    action: experimentData
                }

                Label {
                    anchors {
                        bottom: image.bottom
                    }
                    font.pixelSize: 24
                    font.weight: Font.Light
                    text: experimentData.id
                }
            }

            Item {
                width: 1
                height: 24
            }

            ExperimentEdit {
                experimentData: root.experimentData
                property: "type"
                text: "Action type"
            }

            ExperimentEdit {
                experimentData: root.experimentData
                property: "location"
                text: "Location"
            }

            ExperimentEdit {
                experimentData: root.experimentData
                property: "datetime"
                text: "Date and time"
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

            Item {
                width: 1
                height: 24
            }

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 100
                    rightMargin: 48
                }

                Label {
                    id: modulesTitle
                    font.pixelSize: 24
                    font.weight: Font.Light
                    color: "#434343"
                    horizontalAlignment: Text.AlignRight
                    text: "Modules"
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Button {
                    id: addModuleButton
                    text: "Add module"
                    onClicked: {
                        newModuleDialog.open()
                    }
                }

            }

            Label {
                id: modulesLoadingText
                visible: false
                x: 100
                color: "#ababab"
                text: "Loading ..."
            }

            Label {
                x: 100
                visible: !modulesLoadingText.visible && modulesModel.count < 1
                color: "#ababab"
                text: "No modules"
            }

            Dialog {
                id: newModuleDialog
                standardButtons: Dialog.Ok | Dialog.Cancel
                Column {
                    id: newModuleColumn
                    spacing: 8
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: 18
                        text: "New module"
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: "Template:"
                    }

                    ComboBox {
                        id: templateSelector
                        property var currentItem: currentIndex > -1 ? model.get(currentIndex) : {key: "", value: "", name: ""}
                        textRole: "key"
                        model: ListModel {
                            ListElement { key: "None"; value: '{"value": false}' }
                            ListElement { key: "Tracking"; name: "tracking"; value: '{"box_size": false, "wireless": false, "camera": false, "ttl_channel": false}' }
                            ListElement { key: "Grating"; name: "grating";value: '{"directions": false, "duration": false, "distance": false}' }
                        }
                        onActivated: {
                            nameField.text = model.get(index).name
                        }
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: "Name: "
                    }

                    TextField {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        id: nameField
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        color: "#ababab"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: "(Permanent: Cannot be changed)"
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: "Contents:"
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: "#545454"
                        text: templateSelector.currentItem.value
                    }
                }
                onAccepted: {
                    var selection = templateSelector.model.get(templateSelector.currentIndex)
                    var value = selection.value
                    var name = nameField.text
                    if(!value || !name) {
                        console.log("ERROR: Missing name or value")
                        return
                    }
                    var target = "modules/" + experimentData.project + "/" + experimentData.id + "/" + name
                    var targetProperty = root.property
                    var data = JSON.parse(value)
                    Firebase.put(target, data, function(req) {
                        console.log("Add module result:", req.status, req.responseText)
                        templateSelector.currentIndex = 0
                    })
                }
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
        }
    }


    Popup {
        id: codePopup
        modal: true
        focus: true
        dim: true
        x: root.width / 2 - width / 2
        y: root.height / 2 - height / 2
        width: 320
        height: 180
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        Label {
            anchors {
                fill: parent
                margins: 32
            }

            text: "Code copied to clipboard\n\n" +
                  "Paste it in a Jupyter Notebook to load the experiment."
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }
}
