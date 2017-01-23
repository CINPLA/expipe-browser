import QtQuick 2.4
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0

//import ExpipeBrowser 1.0
//import QtWebView 1.1
import QtWebEngine 1.0

import "md5.js" as MD5
import "firebase.js" as Firebase

QQC1.ApplicationWindow {
    id: root

    visible: true
    width: 1440
    height: 1024
    title: qsTr("CINPLA Browser")

    property bool hasToken: false
    property var xhr

    onHasTokenChanged: {
        if(hasToken) {
            experimentsView.retryConnection()
        }
    }

//    Row {
////        Button {
////            onClicked: {
////                if(xhr) {
////                    xhr.close()
////                }

////                xhr = Firebase.listen(root, "subjects", function(path, value) {
////                    console.log("Got put", path, JSON.stringify(value))
////                })
////            }
////            text: "firebase"
////        }
////        Button {
////            onClicked: {
////                if(!xhr) {
////                    xhr = new XMLHttpRequest
////                }
////                xhr.open("GET", Firebase.server_url + "actions.json?auth=" + Firebase.auth)
////                xhr.onreadystatechange = function() {
////                    console.log(xhr.readyState, xhr.responseText)
////                }
////                xhr.setRequestHeader("Accept", "text/event-stream")
////                xhr.send()
////            }
////            text: "send"
////        }
////        Button {
////            onClicked: {
////                xhr.open("GET", Firebase.server_url + "actions.json?auth=" + Firebase.auth)
////                xhr.setRequestHeader("connection", "close")
////                xhr.send()
////            }
////            text: "abort"
////        }

//        Button {
//            text: "EventScript"
//            onClicked: {
//                webView.runJavaScript("new EventSource('https://expipe-26506.firebaseio.com/')", function(eventSource) {
//                    console.log("EventSource", eventSource)
//                })
//            }
//        }
//    }
    Component.onCompleted: {
        //        console.log("Initializing firebase")
        //        Firebase.initialize(Firebase, root)
        //        Firebase.test(function (result) {

        //        })
        //        console.log(Firebase.blah)
    }

        Settings {
            property alias width: root.width
            property alias height: root.height
        }

        LeftMenu {
            id: leftMenu
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            width: 240
        }

        Item {
            id: viewArea
            anchors {
                left: leftMenu.right
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
        }

        ExperimentsView {
            id: experimentsView
            anchors.fill: viewArea
            visible: leftMenu.selectedState === "experiments"
        }

    //    ProjectsView {
    //        id: projectsView
    //        anchors.fill: viewArea
    //        visible: leftMenu.selectedState === "projects"
    //    }

    WebEngineView {
        id: webView
        anchors.fill: parent
        url: "http://cinpla.org/expipe/auth/"
        visible: !hasToken
    }

    Timer {
        running: true
        interval: 1000
        repeat: true
        onTriggered: {
            webView.runJavaScript("globalToken", function(globalToken) {
//                console.log("Global token", globalToken)
                if(globalToken) {
                    Firebase.auth = globalToken
                    hasToken = true
                } else {
                    hasToken = false
                }
            })
        }
    }
}
