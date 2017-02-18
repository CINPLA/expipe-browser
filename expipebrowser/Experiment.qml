import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "."

import "md5.js" as MD5
import "dicthelper.js" as DictHelper

Rectangle {
    id: root

    property var experimentData
    property string currentProject

    property var modules: {
        return {}
    }

    color: "#fdfdfd"
    border {
        color: "#dedede"
        width: 1
    }

    function refreshModules(path) {
        if(path.length < 1) {
            return
        }
        for(var i = 0; i < moduleView.count; i++) {
            var dictEditor = moduleView.itemAt(i)
            if(dictEditor.key === path[0]) {
                dictEditor.refreshPath(path)
            }
        }
    }

    EventSource {
        id: eventSource
        path: experimentData ? "modules/" + currentProject + "/" + experimentData.__key : ""

        onPutReceived: {
            refreshModules(path)
        }
        onPatchReceived: {
            refreshModules(path)
        }
    }

    Clipboard {
        id: clipboard
    }

    Flickable {
        anchors.fill: parent
        contentHeight: container.height + 360
        // ScrollBar.vertical: ScrollBar {}

        Button {
            id: codeButton
            property string snippet: "import expipe.io\n" +
                                     "project = expipe.io.get_project('" + experimentData.project+ "')\n" +
                                     "action = project.require_action('" + experimentData.__key + "')\n" +
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
                    text: experimentData["__key"]
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
                x: 100
                visible: eventSource.status != EventSource.Connected
                color: "#ababab"
                text: {
                    switch(eventSource.status) {
                    case EventSource.Connecting:
                        return "Loading..."
                    case EventSource.Disconnected:
                        return "Error loading modules!"
                    }
                    return ""
                }
            }

            Label {
                x: 100
                visible: !modulesLoadingText.visible && moduleView.count < 1
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
                    
                    EventSource {
                        id: templateEventSource
                        path: "templates"
                    }

                    ComboBox {
                        id: templateSelector
                        property var currentItem: currentIndex > -1 ? model.data(model.index(currentIndex, 0), 258) : {key: "", value: "", name: ""}
                        textRole: "key"
                        model: templateEventSource
                        onActivated: {
                            nameField.text = model.data(model.index(currentIndex, 0), 258).identifier
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
                        // wrapMode: Text.WrapAtWordBoundaryOrAnywhere
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
                        text: JSON.stringify(templateSelector.currentItem.contents)
                    }
                }
                onAccepted: {
                    var selection = templateSelector.currentItem
                    var name = nameField.text
                    var data = selection.contents
                    if(!data || !name) {
                        console.log("ERROR: Missing name or value")
                        return
                    }
                    var target = "modules/" + currentProject + "/" + experimentData.__key + "/" + name
                    var targetProperty = root.property
                    Firebase.put(target, data, function(req) {
                        console.log("Add module result:", req.status, req.responseText)
                        templateSelector.currentIndex = 0
                    })
                }
            }

            Repeater {
                id: moduleView
                model: eventSource
                DictionaryEditor {
                    property string key: model.key
                    x: 100
                    keyString: model.key
                    contents: model.contents
                    basePath: "modules/" + currentProject + "/" + experimentData.__key + "/" + model.key
                    onContentsChanged: {
                        console.log("Contents changed", JSON.stringify(contents))
                    }
                }
            }
        }
    }


    // Popup {
    //     id: codePopup
    //     modal: true
    //     focus: true
    //     dim: true
    //     x: root.width / 2 - width / 2
    //     y: root.height / 2 - height / 2
    //     width: 320
    //     height: 180
    //     closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    //     Label {
    //         anchors {
    //             fill: parent
    //             margins: 32
    //         }
    // 
    //         text: "Code copied to clipboard\n\n" +
    //               "Paste it in a Jupyter Notebook to load the experiment."
    //         wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    //     }
    // }
}
