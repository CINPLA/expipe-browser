import ctypes
from ctypes.util import find_library

# OpenGL fix (must be set before other imports)
libGL = find_library("GL")
ctypes.CDLL(libGL, ctypes.RTLD_GLOBAL)

import sys
import re
import os

from PyQt5.QtCore import pyqtProperty, QObject, QUrl, pyqtSignal, pyqtSlot, QRegularExpression, QByteArray, QStandardPaths
from PyQt5.QtWidgets import QApplication
from PyQt5.QtWebEngine import QtWebEngine
from PyQt5.QtNetwork import QNetworkReply, QNetworkRequest, QNetworkAccessManager, QNetworkDiskCache
from PyQt5.QtQml import qmlRegisterType, QQmlComponent, QQmlApplicationEngine, QQmlNetworkAccessManagerFactory

from expipe import settings

class EventSource(QObject):
    event_received = pyqtSignal([str, str], name="eventReceived")
    url_changed = pyqtSignal("QUrl", name="urlChanged")
    
    def __init__(self, parent=None):
        super().__init__(parent)

        self._url = QUrl()
        self._type = ""
        self._data = ""
        self._manager = QNetworkAccessManager(self)
        self._reply = None

    @pyqtProperty('QUrl')
    def url(self):
        return self._url

    @url.setter
    def url(self, url):
        if url == self._url:
            return
        self._url = url
        self.reconnect(url)
        self.url_changed.emit(url)
        
    @pyqtProperty('QString', notify=url_changed)
    def data(self):
        return self._data
        
    @pyqtProperty('QString')
    def type(self):
        return self._type
        
    def reconnect(self, url):
        print("Reconnecting")
        if self._reply is not None:
            self._reply.abort()
            self._reply = None
        request = QNetworkRequest(url)
        request.setRawHeader(b"Accept", b"text/event-stream")
        self._reply = self._manager.get(request)
        self._reply.readyRead.connect(self.processReadyRead)
        self._reply.finished.connect(self.processFinished)

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
            self.reconnect(url)
        #reply.deleteLater()
            

class Clipboard(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
    
    @pyqtSlot(str)
    def setText(self, text):
        QApplication.clipboard().setText(text)

class NetworkAccessManagerFactory(QQmlNetworkAccessManagerFactory):
    def create(self, parent):
        nam = QNetworkAccessManager(parent)
        cache = QNetworkDiskCache(parent)
        cache_dir = QStandardPaths.writableLocation(QStandardPaths.CacheLocation)
        cache_subdir = os.path.join(cache_dir, "network")
        print("Cache dir:", cache_subdir)
        cache.setCacheDirectory(cache_subdir)
        nam.setCache(cache)
        return nam

if __name__ == "__main__":
    app = QApplication(sys.argv)
    qmlRegisterType(EventSource, "ExpipeBrowser", 1, 0, "EventSource")
    qmlRegisterType(Clipboard, "ExpipeBrowser", 1, 0, "Clipboard")
    QApplication.setOrganizationName("Cinpla")
    QApplication.setApplicationName("Expipe Browser")
    QtWebEngine.initialize()
    engine = QQmlApplicationEngine()
    engine.setNetworkAccessManagerFactory(NetworkAccessManagerFactory())
    engine.load(QUrl("main.qml"))

    app.exec_()
