import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ExpipeBrowser 1.0

import "md5.js" as MD5

Item {
    id: root
    
    ExperimentList {
        id: experimentList
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        model: SqlQueryModel {
            query: "SELECT * FROM experiments " +
                   "ORDER BY registered DESC"
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
}
