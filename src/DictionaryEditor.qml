import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0

import "firebase.js" as Firebase

Column {
    id: column
    signal refreshParent()
    property string basePath
    property var contents: []
    property var contentsModel: []
    property var path: []
    property alias repeater: repeater
    property int level: 0
    property var object
    property var parentObject
    property bool isLastItem: true
    property bool expanded: false
    property bool isRoot: false
    property bool hasChanges: textField.text !== backendText
    property bool isObject: type === "object"
    property color readyColor: "#121212"
    property color waitingColor: "#979797"

    property string backendText: {
        if(type === "null") {
            return ""
        }
        if(type === "string") {
            return '"' + value.replace('"', '\\"') + '"'
        }
        if(type === "number") {
            return value
        }
        if(value === undefined) {
            return "undefined"
        }
        return value.toString()
    }

    property string key: {
        if(path.length === 0) {
            return ""
        }
        return path[path.length - 1]
    }

    property string keyString: {
        if(path.length === 0) {
            return "root"
        }
        return key
    }

    property var value: {
        if(object === undefined) {
            return null
        }
        return object
    }

    property string type: {
        if(value === null) {
            return "null"
        }
        return typeof(value)
    }

//    function refresh() {
//        updateObject()
//        updateModel()
//        refreshParent()
//    }

    function refreshPath(pathSplit) {
        console.log("Requested refresh on", pathSplit)
//        updateObject()
//        updateModel()
        if(pathSplit.length === 0) {
            console.log("Updating on", path, key)
            updateObject()
            updateModel()
            return
        }
        var nextKey = pathSplit.shift() // first item is removed
        for(var i in contentsModel) {
            if(contentsModel[i].key === nextKey) {
                console.log("Passing on to", nextKey)
                var subEditor = repeater.itemAt(i).editor
                subEditor.refreshPath(pathSplit)
            }
        }
    }

    function updateObject() {
        var self = contents
        console.log("Self", JSON.stringify(contents))
        var parent = null
        for(var i in path) {
            var subPath = path[i]
            parent = self
            self = self[subPath]
            console.log("Sub", subPath, JSON.stringify(self))
        }
        object = self
        parentObject = parent
        textField.reset()
        console.log("Backend value", backendText, object)
    }

    function createModel() {
        var model = []
        if(!isObject) {
            return model
        }
        for(var i in object) {
            model.push({"key": i, "value": object[i]})
        }
        return model
    }

    function updateModel() {
        contentsModel = createModel()
    }

    function isNumeric(num) {
        return !isNaN(num)
    }

    function parseInput(input) {
        console.log("Input", input)
        if(input === "") {
            console.log("Empty string")
            return null
        }
        try {
            var obj = JSON.parse(input)
            console.log("Parsed!", JSON.stringify(obj))
            return obj
        } catch (e) {
            console.log("Failed parse", e)
        }

        var output = input
        if(isNumeric(input)) {
            output = parseFloat(input)
            console.log("Is numeric", output)
        } else {
            output = input.replace('\\"', '"')
            console.log("Is string", output)
            if(output[0] === '"' && output[output.length - 1] === '"') {
                output = output.substring(1, output.length - 1)
                console.log("substring", output)
            }
        }
        return output
    }

    function putChanges(callback) {
        if(!hasChanges) {
            console.log("No change, returning")
            return
        }
        var name = basePath + "/" + path.join("/")
        var data = parseInput(textField.text)
        Firebase.put(name, data, function(req) {
            console.log("Patch result:", req.status, req.responseText)
            textField.text = Qt.binding(function() {return backendText})
            textField.readOnly = false
            textField.color = column.readyColor
            if(callback) {
                callback()
            }
        })
        textField.readOnly = true
        textField.color = column.waitingColor
    }

//    onPathChanged: {
//        updateObject()
//        updateModel()
//    }

    onContentsChanged: {
        for(var i = 0; i < repeater.count; i++) {
            var subEditor = repeater.itemAt(i).editor
            subEditor.contents = contents
        }
    }

    Component.onCompleted: {
        updateObject()
        updateModel()
    }

    Item {
        width: elementRow.width
        height: 33
        MouseArea {
            id: elementArea
            anchors.fill: parent

            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
        Row {
            id: elementRow
            spacing: 4
            height: 33

            Item {
                width: 33
                height: 33
                clip: true
                visible: !column.isRoot
                Image {
                    source: "grid.png"
                    x: -33 * 3
                    visible: !column.isLastItem
                }
                Image {
                    source: "grid.png"
                    x: {
                        if(column.isObject) {
                            return column.expanded ? 0 : -33
                        } else {
                            return -33 * 2
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: column.expanded = !column.expanded
                }
            }

            Text {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                text: column.keyString + ":"
                font.weight: Font.Bold
                color: "#333"
            }

            Rectangle {
                id: rect
                property bool show: mouseArea.containsMouse || textField.activeFocus
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                visible: !column.isObject
                width: textField.width + 16
                height: textField.height + 8
                color: show ? "white" : "transparent"
                border {
                    color: show ? "black" : "transparent"
                    width: 1
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    propagateComposedEvents: true
                    hoverEnabled: true
                    cursorShape: Qt.IBeamCursor
                    onClicked: {
                        textField.forceActiveFocus()
                        mouse.accepted = false
                    }
                }

                TextInput {
                    id: textField

                    anchors.centerIn: parent

                    color: "#111"
                    text: backendText

                    onEditingFinished: {
                        putChanges()
                    }

                    function reset() {
                        text = Qt.binding(function() {return backendText})
                    }

                    Keys.onReturnPressed: {
                        focus = false
                    }

                    Keys.onEscapePressed: {
                        reset()
                        focus = false
                    }
                }
            }
            MouseArea {
                anchors.verticalCenter: parent.verticalCenter
                width: plus.width + 4
                height: plus.height + 4
                visible: column.isObject

                onClicked: {
                    newRow.visible = true
                }

                Text {
                    id: plus
                    anchors.centerIn: parent
                    color: "green"
                    visible: elementArea.containsMouse
                    text: "+"
                }
            }
            MouseArea {
                anchors.verticalCenter: parent.verticalCenter
                width: minus.width + 4
                height: minus.height + 4

                onClicked: {
                    console.log("TODO: Deletion needs to be implemented")
//                    delete(column.parentObject[column.key])
//                    column.refresh()
                }

                Text {
                    id: minus
                    anchors.centerIn: parent
                    color: "red"
                    text: "x"
                    visible: elementArea.containsMouse
                }
            }
        }
    }

    Row {
        visible: column.expanded
        Item {
            width: 33
            height: col.height
            clip: true
            visible: !column.isRoot
            Image {
                visible: !column.isLastItem
                x: -33 * 3
                height: parent.height
                fillMode: Image.TileVertically
                source: "grid.png"
            }
        }

        Column {
            id: col

            Repeater {
                id: repeater

                model: column.contentsModel

                delegate: Item {
                    property var editor: loader.item
                    width: loader.width
                    height: loader.height

                    Loader {
                        id: loader

                        Component.onCompleted: {
                            var subPath = column.path.slice()
                            subPath.push(modelData.key)
                            setSource("DictionaryEditor.qml", {
                                          contents: column.contents,
                                          path: subPath,
                                          isLastItem: (index === repeater.count - 1),
                                          isRoot: false,
                                          basePath: column.basePath
                                      })
                        }

                        Connections {
                            target: loader.item
                            onRefreshParent: {
//                                column.refresh()
                            }
                        }
                    }
                }
            }
        }
    }

    Row {
        id: newRow
        visible: false

        x: 33 * 2

        function accept() {
            console.log("TODO: New needs to be implemented")
//            console.log("Accept")
//            column.object[nameInput.text] = parseInput(valueInput.text)

//            column.refresh()
//            nameInput.text = ""
//            valueInput.text = ""
//            templateSelector.currentIndex = 0
//            visible = false
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            font.weight: Font.Bold
            text: "Name:"
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: nameInput.width + 16
            height: nameInput.height + 8
            TextInput {
                id: nameInput
                width: 100
                anchors.centerIn: parent
                clip: true

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    cursorShape: Qt.IBeamCursor
                }
            }
            Text {
                anchors.fill: nameInput
                text: "a good name"
                color: "#999"
                visible: !nameInput.text
            }
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            font.weight: Font.Bold
            text: "Value:"
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: valueInput.width + 16
            height: valueInput.height + 8
            visible: templateSelector.currentIndex === 0
            TextInput {
                id: valueInput
                width: 160
                clip: true

                anchors.centerIn: parent
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    cursorShape: Qt.IBeamCursor
                }
            }
            Text {
                anchors.fill: valueInput
                text: "with a fine value"
                color: "#999"
                visible: !valueInput.text
            }
            Keys.onReturnPressed: {
                newRow.accept()
            }
        }

        ComboBox {
            id: templateSelector
            textRole: "key"
            model: ListModel {
                ListElement { key: "Templates"; inactive: true }
                ListElement { key: "Tracking"; value: '{"box_size": null, "wireless": false, "camera": null, "ttl_channel": null}' }
                ListElement { key: "Grating"; value: '{"directions": null, "duration": false, "distance": null}' }
            }
            onActivated: {
                if(!model.get(index).value) {
                    valueInput.text = ""
                }
                valueInput.text = model.get(index).value
            }
        }

        Button {
            text: "OK"
            onClicked: {
                newRow.accept()
            }
        }

        Button {
            text: "Cancel"
            onClicked: {
                newRow.visible = false
            }
        }
    }
}
