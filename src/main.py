import ctypes
from ctypes.util import find_library

# OpenGL fix (must be set before other imports)
libGL = find_library("GL")
ctypes.CDLL(libGL, ctypes.RTLD_GLOBAL)

import sys
import re

from PyQt5.QtCore import pyqtProperty, QObject, QUrl, pyqtSignal, pyqtSlot, QRegularExpression, QByteArray
from PyQt5.QtWidgets import QApplication
from PyQt5.QtWebEngine import QtWebEngine
from PyQt5.QtNetwork import QNetworkReply, QNetworkRequest, QNetworkAccessManager
from PyQt5.QtQml import qmlRegisterType, QQmlComponent, QQmlApplicationEngine

from expipe import settings

class EventSource(QObject):
    event_received = pyqtSignal([str, str], name="eventReceived")
    
    def __init__(self, parent=None):
        super().__init__(parent)

        self._url = QUrl()
        self._type = ""
        self._data = ""
        self._manager = QNetworkAccessManager(self)

    @pyqtProperty('QUrl')
    def url(self):
        return self._url

    @url.setter
    def url(self, url):
        self._url = url
        self.reconnect()
        
    @pyqtProperty('QString')
    def data(self):
        return self._data
        
    @pyqtProperty('QString')
    def type(self):
        return self._type
        
    def reconnect(self):
        request = QNetworkRequest(self._url)
        request.setRawHeader(b"Accept", b"text/event-stream")
        reply = self._manager.get(request)
        reply.readyRead.connect(self.processReadyRead)
        reply.finished.connect(self.processFinished)

    def processReply(self, reply):
        pass

    def processReadyRead(self):
        reply = self.sender()
        if not reply:
            return
        contents = bytes(reply.readAll().trimmed()).decode("utf-8")
        lines = contents.split("\n")
        if len(lines) < 2:
            print("ERROR: Too few lines in event!")
            print("Contents:", contents)
            return
        eventLine = lines[0]
        dataLine = lines[1]
        if eventLine.startswith("event:") and dataLine.startswith("data:"):
            eventLine = re.sub(r"^event:\s*", "", eventLine)
            self._type = eventLine.strip()
            dataLine = re.sub(r"^data:\s*", "", dataLine)
            self._data = dataLine.strip()
            self.eventReceived.emit(self._type, self._data)
        else:
            print("ERROR: Got corrupted event line")
            print("Contents:", contents)
            return

    def processFinished(self):
        reply = self.sender()
        if not reply:
            return
        url = reply.attribute(QNetworkRequest.RedirectionTargetAttribute)
        if url:
            self.url = url
            reply.deleteLater()


app = QApplication(sys.argv)
qmlRegisterType(EventSource, "ExpipeBrowser", 1, 0, "EventSource")
QtWebEngine.initialize()
engine = QQmlApplicationEngine()
engine.load(QUrl("main.qml"))

app.exec_()
