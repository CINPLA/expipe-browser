import ctypes
from ctypes.util import find_library

# OpenGL fix (must be set before other imports)
libGL = find_library("GL")
ctypes.CDLL(libGL, ctypes.RTLD_GLOBAL)

import sys
import re
import os
import json
from collections import OrderedDict

from PyQt5.QtCore import Qt, pyqtProperty, QObject, QUrl, pyqtSignal, pyqtSlot, QRegularExpression, QByteArray, QStandardPaths, QAbstractListModel, QModelIndex
from PyQt5.QtWidgets import QApplication
from PyQt5.QtWebEngine import QtWebEngine
from PyQt5.QtNetwork import QNetworkReply, QNetworkRequest, QNetworkAccessManager, QNetworkDiskCache
from PyQt5.QtQml import qmlRegisterType, QQmlComponent, QQmlApplicationEngine, QQmlNetworkAccessManagerFactory

from expipe import settings

class EventSource(QAbstractListModel):
    event_received = pyqtSignal([str, str], name="eventReceived")
    url_changed = pyqtSignal("QUrl", name="urlChanged")

    key_role = Qt.UserRole + 1
    contents_role = Qt.UserRole + 2
    
    def __init__(self, parent=None):
        super().__init__(parent)

        self._url = QUrl()
        self._type = ""
        self.data = ""
        self.manager = QNetworkAccessManager(self)
        self.reply = None
        self.contents = {}

    @pyqtProperty('QUrl')
    def url(self):
        return self.url

    @url.setter
    def url(self, url):
        if url == self._url:
            return
        self._url = url
        self.reconnect(url)
        self.url_changed.emit(url)

    def data(self, index=QModelIndex(), role=0):
        print("Data requested", index, role)
        if role == self.key_role:
            key_list = list(self.contents.keys())
            return key_list[index.row()]
        elif role == self.contents_role:
            value_list = list(self.contents.values())
            return value_list[index.row()]
        else:
            return QVariant()
        
    @pyqtProperty('QString')
    def type(self):
        return self._type

    def rowCount(self, index=QModelIndex()):
        return len(self.contents)

    def roleNames(self):
        return {
            self.key_role: b"key",
            self.contents_role: b"contents"
        }
        
    def reconnect(self, url):
        print("Reconnecting")
        if self.reply is not None:
            self.reply.abort()
            self.reply = None
        request = QNetworkRequest(url)
        request.setRawHeader(b"Accept", b"text/event-stream")
        self.reply = self.manager.get(request)
        self.reply.readyRead.connect(self.processReadyRead)
        self.reply.finished.connect(self.processFinished)

    def processReply(self, reply):
        pass

    def set_path_value(self, path, value):
        dic = self.contents
        for key in path[:-1]:
            dic = dic.setdefault(key, {})
        if value is None:
            del(dic[path[-1]])
        else:
            dic[path[-1]] = value

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
            self.data = dataLine.strip()
            self.eventReceived.emit(self._type, self.data)

            if self._type == "put":
                event = json.loads(self.data)
                path = event["path"].split("/")
                if path[0] == "":
                    del(path[0])
                if path[-1] == "":
                    del(path[-1])
                data = event["data"]

                if len(path) == 0:
                    self.beginRemoveRows(QModelIndex(), 0, self.rowCount())
                    self.endRemoveRows()
                    self.beginInsertRows(QModelIndex(), 0, len(data) - 1)
                    self.contents = OrderedDict(data)
                    self.endInsertRows()
                else:
                    changed_key = path[0]
                    key_list = list(self.contents.keys())
                    if changed_key in key_list:
                        index = key_list.index(changed_key)
                        model_index = self.index(index, 0)
                        if len(path) == 1 and data is None:
                            self.beginRemoveRows(QModelIndex(), index, index)
                            self.set_path_value(path, data)
                            self.endRemoveRows()
                        else:
                            self.set_path_value(path, data)
                            self.dataChanged.emit(model_index, model_index)
                    else:
                        self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
                        self.set_path_value(path, data)
                        self.endInsertRows()


                print(path, data)
                print("Contents", self.contents)

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
        super()._init__(parent)
    
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
