import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

//import ExpipeBrowser 1.0

import "md5.js" as MD5

Item {
    id: root

    Rectangle {
        id: projectList
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: 400

        color: "#efefef"
        border {
            color: "#dedede"
            width: 1
        }

        ListView {
            id: listView
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: parent.left
            }
            ScrollBar.vertical: ScrollBar {}
            model: SqlQueryModel {
                query: "SELECT project_id, project_name, COUNT(*) as experiment_count " +
                       "FROM experiments " +
                       "GROUP BY project_id, project_name " +
                       "ORDER BY project_name"
            }
            delegate: Item {
                property variant modelData: model
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: 64

                Column {
                    spacing: 10
                    anchors {
                        margins: 12
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    Text {
                        color: "#545454"
                        text: project_name
                        font.pixelSize: 14
                    }
                    Text {
                        color: "#545454"
                        text: experiment_count + " experiments"
                        font.pixelSize: 12
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
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

    ExperimentList {
        id: experimentList
        anchors {
            left: projectList.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 400
        model: SqlQueryModel {
            query: {
                if(listView.currentItem) {
                    return "SELECT * FROM experiments " +
                            "WHERE project_id = '" + listView.currentItem.modelData.project_id + "' " +
                            "ORDER BY registered DESC"
                } else {
                    return "SELECT * FROM experiments " +
                            "ORDER BY registered DESC"
                }
            }
        }
    }

    Experiment {
        anchors {
            left: experimentList.right
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        experimentData: experimentList.currentData
        imageSource: experimentList.currentImageSource
    }
}
