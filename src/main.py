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
import expipe.io

#streams = []

import time

#class StreamHandler(QObject):
#    def __init__(self, eventSource, path):
#        super().__init__(eventSource)
#        self.open = True
#        print("Setting up stream")
#        self.stream = expipe.io.core.db.child(path).stream(self.handle_message)
#        print("Stream ready")
#        self.eventSource = eventSource
#        streams.append(self.stream)

#    def close(self):
#        streams.remove(self.stream)
#        try:
#            print("Closing stream...")
#            self.stream.close()
#            print("Stream closed")
#        except AttributeError:
#            print("Warning: Trouble closing stream. This is normal.")
#        self.open = False


class EventSource(QAbstractListModel):
    path_changed = pyqtSignal("QString", name="pathChanged")

    key_role = Qt.UserRole + 1
    contents_role = Qt.UserRole + 2

    def __init__(self, parent=None):
        super().__init__(parent)

        self._path = ""
        self.contents = {}
        self.stream_handler = None
        self._reply = None
        self._manager = QNetworkAccessManager(self)

    def __del__(self):
        print("Got deleted...")

    def refresh(self):
        for key in self.contents:
            try:
                self.contents[key]["__key"] = key
                self.contents[key]["__path"] = self._path + "/" + key
            except TypeError:
                pass

    def process_put(self, path, data):
        if len(path) == 0:
            self.beginRemoveRows(QModelIndex(), 0, self.rowCount() - 1)
            self.contents = OrderedDict({})
            self.endRemoveRows()
            if data is not None:
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
                    self.set_nested(path, data)
                    self.endRemoveRows()
                else:
                    self.set_nested(path, data)
                    self.dataChanged.emit(model_index, model_index)
            else:
                self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
                self.set_nested(path, data)
                self.endInsertRows()
        self.refresh()

    def disconnect(self):
        if self._reply is not None:
            self._reply.abort()
            self._reply = None

    def reconnect(self, url):
        self.disconnect()
        request = QNetworkRequest(url)
        request.setRawHeader(b"Accept", b"text/event-stream")
        self._reply = self._manager.get(request)
        self._reply.readyRead.connect(self.processReadyRead)
        self._reply.finished.connect(self.processFinished)

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
            event_type = eventLine.strip()
            dataLine = re.sub(r"^data:\s*", "", dataLine)
            event_data = dataLine.strip()
            message = json.loads(event_data) # sets path and data
            if message:
                path = message["path"]
                data = message["data"]
                path = path.split("/")
                if path[0] == "":
                    del(path[0])
                if path[-1] == "":
                    del(path[-1])
                if event_type == "put":
                    self.process_put(path, data)
                elif event_type == "patch":
                    for key in data:
                        self.process_put(path + [key], data[key])
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

    @pyqtProperty('QString')
    def path(self):
        return self._path

    @path.setter
    def path(self, path):
        if path == self._path:
            return
        self._path = path
        self.process_put([], {})
        if path == "":
            self.disconnect()
        else:
            target = expipe.io.core.db.child(path).order_by_key()
            url_str = target.build_request_url(token=expipe.io.core.user["idToken"])
            url = QUrl(url_str)
            self.reconnect(url)
        self.path_changed.emit(path)

    def data(self, index=QModelIndex(), role=0):
        if role == self.key_role:
            key_list = list(self.contents.keys())
            return key_list[index.row()]
        elif role == self.contents_role:
            value_list = list(self.contents.values())
            return value_list[index.row()]
        else:
            return QVariant()

    def rowCount(self, index=QModelIndex()):
        return len(self.contents)

    def roleNames(self):
        return {
            self.key_role: b"key",
            self.contents_role: b"contents"
        }

    def set_nested(self, path, value):
        dic = self.contents
        for key in path[:-1]:
            dic = dic.setdefault(key, {})
        if value is None:
            del(dic[path[-1]])
        else:
            dic[path[-1]] = value

class Pyrebase(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

    def patch(self, name, data):
        db.child(name).patch(data)


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
    qmlRegisterType(EventSource, "ExpipeBrowser", 1, 0, "Pyrebase")
    qmlRegisterType(Clipboard, "ExpipeBrowser", 1, 0, "Clipboard")
    QApplication.setOrganizationName("Cinpla")
    QApplication.setApplicationName("Expipe Browser")
    QtWebEngine.initialize()
    engine = QQmlApplicationEngine()
    engine.setNetworkAccessManagerFactory(NetworkAccessManagerFactory())
    engine.load(QUrl("main.qml"))

    app.exec_()
            
