import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import CinplaBrowser 1.0

import "md5.js" as MD5

//import io.thp.pyotherside 1.3

ApplicationWindow {
    visible: true
    width: 1440
    height: 1024
    title: qsTr("CINPLA Browser")

    Action {
        id: loadDataAction
        shortcut: StandardKey.Open
        onTriggered: experimentModel.loadData()
        text: qsTr("&Load data")
    }

    //    menuBar: BrowserMenuBar {
    //        loadDataAction: loadDataAction
    //    }

    RowLayout {
        spacing: 0
        anchors.fill: parent
        Rectangle {
            id: leftMenu

            Layout.fillHeight: true
            Layout.preferredWidth: 240

            color: "#363636"

            ListModel {
                id: menuModel
                ListElement {
                    name: "Experiments"
                }
                ListElement {
                    name: "Users"
                }
                ListElement {
                    name: "Analyses"
                }
            }

            TextField {
                id: searchField
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 20
                }
                placeholderText: "Search"
            }

            ListView {
                id: menuView
                anchors {
                    top: searchField.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: 24
//                    margins: 20
                }
                model: menuModel
                delegate: Item {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: 36
                    Text {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                            leftMargin: 24
                            rightMargin: 24
                        }

                        color: "white"
                        text: name
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            menuView.currentIndex = index
                        }
                    }
                }
                highlight: Rectangle {
                    color: "white"
                    opacity: 0.1
                }
                clip: true
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 400
            color: "#efefef"
            border {
                color: "#dedede"
                width: 1
            }

            ExperimentModel {
                id: experimentModel
            }

            Rectangle {
                id: stuff
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 36
                color: "#cecece"

                Text {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 20
                    }
                    text: "21 experiments sorted by experimenter"
                    color: "#787878"
                    font.pixelSize: 14
                }
            }

            ListView {
                id: experimentView
                anchors {
                    top: stuff.bottom
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                }
                model: experimentModel
                delegate: Item {
                    property variant modelData: model
                    property string imageSource: "http://gravatar.com/avatar/" + MD5.md5(email)
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: 64

                    Item {
                        id: imageItem
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            leftMargin: 16
                        }
                        width: height
                        Image {
                            anchors.centerIn: parent
                            width: parent.height * 0.6
                            height: width
                            fillMode: Image.PreserveAspectCrop
                            source: imageSource

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
                            text: experimenter
                        }
                        Text {
                            color: "#545454"
                            text: datetime
                            font.pixelSize: 14
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            experimentView.currentIndex = index
                        }
                    }
                }
                highlightMoveDuration: 400
                highlight: Rectangle {
                    color: "black"
                    opacity: 0.1
                }
                clip: true
            }
        }

        Rectangle {

            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#fefefe"
            border {
                color: "#dedede"
                width: 1
            }

            Flickable {
                anchors.fill: parent
                visible: experimentView.currentItem ? true : false
                contentHeight: container.height + 360
                Column {
                    id: container
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: 48
                    }

                    spacing: 36

                    GridLayout {
                        id: experimentGrid
                        columns: 2
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        columnSpacing: 16
                        rowSpacing: 12

                        Item {
                            Layout.preferredHeight: 72
                            Layout.preferredWidth: 240
                            Image {
                                anchors.right: parent.right
                                width: 64
                                height: 64
                                source: experimentView.currentItem ? experimentView.currentItem.imageSource : ""
                                fillMode: Image.PreserveAspectCrop
                            }
                        }
                        Item {
                            Layout.preferredHeight: 72
                            Layout.fillWidth: true
                            Text {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }
                                text: experimentView.currentItem ? experimentView.currentItem.modelData.datetime : ""
                                font.pixelSize: 34
                                color: "#121212"
                            }
                        }

                        ExperimentLeftGridItem {
                            text: "experimenter"
                        }

                        ExperimentRightGridItem {
                            text: experimentView.currentItem ? experimentView.currentItem.modelData.experimenter : "No experiment selected"
                        }

                        ExperimentLeftGridItem {
                            text: "filename"
                        }


                        ExperimentRightGridItem {
                            text: experimentView.currentItem ? experimentView.currentItem.modelData.filename : ""
                        }

                        ExperimentLeftGridItem {
                            text: "raw filename"
                        }

                        ExperimentRightGridItem {
                            text: experimentView.currentItem ? experimentView.currentItem.modelData.rawpath : ""
                        }
                        ExperimentTitleItem {
                            text: "Anatomy"
                        }
                        ExperimentLeftGridItem {
                            text: "electrode depth"
                        }

                        ExperimentRightGridItem {
                            text: "100 µm"
                        }

                        ExperimentLeftGridItem {
                            text: "electrode delta"
                        }

                        ExperimentRightGridItem {
                            text: "1.5 µm"
                        }

                        ExperimentLeftGridItem {
                            text: "brain area"
                        }

                        ExperimentRightGridItem {
                            text: "hippocampus"
                        }

                        ExperimentTitleItem {
                            text: "Tracking"
                        }
                        ExperimentLeftGridItem {
                            text: "environment"
                        }

                        ExperimentRightGridItem {
                            text: "box"
                        }

                        ExperimentLeftGridItem {
                            text: "size"
                        }

                        ExperimentRightGridItem {
                            text: "1.4 m x 1.2 m"
                        }

                        ExperimentTitleItem {
                            text: "Cells"
                        }
                    }

                    ListModel {
                        id: cellModel
                        ListElement {
                            name: "interneuron 1"
                            spikeCount: 1051
                        }
                        ListElement {
                            name: "interneuron 2"
                            spikeCount: 5415
                        }
                        ListElement {
                            name: "PV cell 1"
                            spikeCount: 879
                        }
                        ListElement {
                            name: "PV cell 2"
                            spikeCount: 12
                        }
                        ListElement {
                            name: "Unknown 1"
                            spikeCount: 945
                        }
                        ListElement {
                            name: "Unknown 2"
                            spikeCount: 872
                        }
                    }

                    Item {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: 120
                        }
                        height: 360

                        TableView {
                            anchors.fill: parent
                            model: cellModel
                            TableViewColumn {
                                title: "Name"
                                role: "name"
                            }
                            TableViewColumn {
                                title: "Spike count"
                                role: "spikeCount"
                            }
                        }
                    }

                    Button {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }

                        text: "Generate input file"
                    }
                }
            }
        }
    }
}

