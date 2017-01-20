import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5

Rectangle {
    property var experimentData
    property string imageSource

    color: "#fefefe"
    border {
        color: "#dedede"
        width: 1
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
                        source: imageSource
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
                        //                                text: currentItem ? currentItem.modelData.datetime : ""  // TODO add back when date and time is stored in database
                        font.pixelSize: 34
                        color: "#121212"
                    }
                }

                ExperimentLeftGridItem {
                    text: "experimenter"
                }

                ExperimentRightGridItem {
                    text: experimentData ? experimentData.experimenter : "No experiment selected"
                }


                ExperimentLeftGridItem {
                    text: "camera"
                }

                ExperimentRightGridItem {
                    text: experimentData ? experimentData.tracking.camera : "No experiment selected"
                }

//                ExperimentLeftGridItem {
//                    text: "e-mail"
//                }

//                ExperimentRightGridItem {
//                    text: experimentData ? experimentData.experimenter : "No experiment selected"
//                }
                
                ExperimentLeftGridItem {
                    text: "filename"
                }
                
                
                ExperimentRightGridItem {
                    text: experimentData ? experimentData.filename : ""
                }
                
                ExperimentLeftGridItem {
                    text: "raw filename"
                }
                
                ExperimentRightGridItem {
                    //                            text: currentItem ? currentItem.modelData.rawpath : "" // TODO add back when full path is stored in database
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
                
                //                        TableView {
                //                            anchors.fill: parent
                //                            model: cellModel
                //                            TableViewColumn {
                //                                title: "Name"
                //                                role: "name"
                //                            }
                //                            TableViewColumn {
                //                                title: "Spike count"
                //                                role: "spikeCount"
                //                            }
                //                        }
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
