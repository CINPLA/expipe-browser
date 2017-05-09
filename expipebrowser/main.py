#!/usr/bin/env python

import sys

if sys.platform == "linux" or sys.platform == "linux2":
    # TODO remove this OpenGL fix when PyQt doesn't require OpenGL to be loaded first. 
    # NOTE This must be placed before any other imports!
    import ctypes
    from ctypes.util import find_library
    libGL = find_library("GL")
    ctypes.CDLL(libGL, ctypes.RTLD_GLOBAL)

import sys
import re
import os
import json
import urllib
from collections import OrderedDict

from PyQt5.QtCore import Q_ENUMS, pyqtProperty, pyqtSignal, pyqtSlot, Qt, QObject, QUrl, QRegularExpression, QByteArray, QStandardPaths, QAbstractListModel, QModelIndex, QVariant
from PyQt5.QtWidgets import QApplication
#from PyQt5.QtWebEngine import QtWebEngine
from PyQt5.QtNetwork import QNetworkReply, QNetworkRequest, QNetworkAccessManager, QNetworkDiskCache
from PyQt5.QtQml import qmlRegisterType, qmlRegisterSingletonType, QQmlComponent, QQmlApplicationEngine, QQmlNetworkAccessManagerFactory

from . import qml_qrc
from expipe import settings
import expipe.io

import time

def deep_convert_dict(layer):
    to_ret = layer
    if isinstance(layer, OrderedDict):
        to_ret = dict(layer)

    try:
        for key, value in to_ret.items():
            to_ret[key] = deep_convert_dict(value)
    except AttributeError:
        pass

    return to_ret
    
# TODO move classes to expipebrowser folder


def parse_event_stream(message, process_event):
    """
    Returns partial message for caller to keep for next call.
    """
    if not message.endswith("\n"):
        print("INFO: Returning partial message because it did not end with a newline.")
        return message
        
    # remove empty lines        
    message_lines = []
    for line in message.splitlines():
        if line.strip() == "":
            continue
        message_lines.append(line)

    if len(message_lines) < 2:
        print("INFO: Returning partial message because number of non-empty lines is < 2.")
        return message
        
    if not message_lines[0].startswith("event:"):
        print("ERROR: EventSource: First line in message should start with 'event:'. Skipping.")
        return parse_event_stream("".join(message_lines[1:]))

    event_name = ""
    event_data = ""

    for line in message_lines:
        line = line.strip()
        splitline = line.split(":", 1)
        if not len(splitline) > 1:
            print("WARNING: EventSource: Caught line without ':':", line)
            continue
        (key, value) = splitline
        key = key.strip()
        value = value.strip()
        
        if key == "event":
            event_name = value
        elif key == "data":
            event_data = value
            process_event(event_name, event_data)
        elif key == "retry":
            try:
                # self.retry_timeout = int(value)  # TODO handle retry
                print("WARNING: Caught retry, but not implemented.")
            except ValueError:
                pass
        elif key == "":
            print("INFO: Received comment:", value)
        else:
            raise Exception("Unknown key!")
    return ""


class EventSource(QAbstractListModel):
    key_role = Qt.UserRole + 1
    contents_role = Qt.UserRole + 2

    class Status:
        Disconnected = 0
        Connected = 1
        Connecting = 2
        Error = 3

    Q_ENUMS(Status)

    def __init__(self, parent=None):
        super().__init__(parent)

        self._path = ""
        self._contents = {}
        self.stream_handler = None
        self._reply = None
        self._manager = QNetworkAccessManager(self)
        self._include_helpers = False
        self._status = self.Status.Disconnected
        self._partial_message = ""
        self._shallow = True

    def __del__(self):
        print("Got deleted...")

    def refresh(self):
        if not self.includeHelpers:
            return
        for key in self._contents:
            try:
                self._contents[key]["__key"] = key
                self._contents[key]["__path"] = self._path + "/" + key
            except TypeError:
                print("Could not set __key", key)
                pass

    def process_put(self, path, data):
        if len(path) == 0:
            self.beginRemoveRows(QModelIndex(), 0, self.rowCount() - 1)
            self._contents = OrderedDict({})
            self.endRemoveRows()
            if data is not None:
                self.beginInsertRows(QModelIndex(), 0, len(data) - 1)
                self._contents = OrderedDict(data)
                self.endInsertRows()
        else:
            changed_key = path[0]
            key_list = list(self._contents.keys())
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
        self.contentsChanged.emit()

    def disconnect(self):
        if self._reply is not None:
            self._reply.abort()
            self._reply = None
        self._partial_message = ""

    def reconnect(self, url):
        self.disconnect()
        request = QNetworkRequest(url)
        request.setRawHeader(b"Accept", b"text/event-stream")
        self._reply = self._manager.get(request)
        self._reply.readyRead.connect(self.processReadyRead)
        self._reply.finished.connect(self.processFinished)
        self.status = self.Status.Connecting
        
    def processEvent(self, event_name, event_data):
        if event_name == "put" or event_name == "patch":
            try:
                contents = json.loads(event_data, object_pairs_hook=OrderedDict)
            except json.decoder.JSONDecodeError as ex:
                print("ERROR: Could not decode on", self._path)
                return
                
            if contents:
                print("Message parsed", self._path)
                path_str = contents["path"]
                data = contents["data"]
                path = path_str.split("/")
                if path[0] == "":
                    del(path[0])
                if path[-1] == "":
                    del(path[-1])
                if event_name == "put":
                    self.process_put(path, data)
                    self.put_received.emit(path, data)
                elif event_name == "patch":
                    for key in data:
                        self.process_put(path + [key], data[key])
                    self.patch_received.emit(path, data)
                self.status = self.Status.Connected
            else:
                print("event_data:", event_data)
                print("event_name:", event_name)
                print("ERROR: Got corrupted event")
        
    def processReadyRead(self):
        reply = self.sender()
        if not reply:
            return

        message = bytes(reply.readAll()).decode("utf-8")
        message = self._partial_message + message
        self._partial_message = parse_event_stream(message, self.processEvent)
        
        if self._partial_message:
            print("WARNING: Received partial message, forcing update by an ugly hack.")
            expipe.io.core.db.child(self._path).update({"__partial_update_hack": True}, expipe.io.core.user["idToken"])
            expipe.io.core.db.child(self._path).update({"__partial_update_hack": None}, expipe.io.core.user["idToken"])

    def processFinished(self):
        reply = self.sender()
        if not reply:
            self.status = self.Status.Disconnected
            return
        url = reply.attribute(QNetworkRequest.RedirectionTargetAttribute)
        if url:
            self.reconnect(url)

    def status(self):
        return self._status

    def setStatus(self, status):
        self._status = status
        self.statusChanged.emit()

    def path(self):
        return self._path

    def setPath(self, path):
        if path == self._path:
            return
        self._path = path
        self.process_put([], {})
        if path == "":
            self.disconnect()
        else:
            target = expipe.io.core.db.child(path).order_by_key().shallow()
            url_str = target.build_request_url(token=expipe.io.core.user["idToken"])
            url = QUrl(url_str)
            self.reconnect(url)
        self.pathChanged.emit()

    def includeHelpers(self):
        return self._include_helpers

    def setIncludeHelpers(self, enabled):
        if self._include_helpers == enabled:
            return
        self._include_helpers = enabled
        self.includeHelpersChanged.emit()

    def data(self, index=QModelIndex(), role=0):
        if role == self.key_role:
            key_list = list(self._contents.keys())
            try:
                return key_list[index.row()]
            except IndexError:
                return None
        elif role == self.contents_role:
            value_list = list(self._contents.values())
            try:
                value = value_list[index.row()]
                value_dict = deep_convert_dict(value)
                return value_dict
            except IndexError:
                return None
        else:
            return None
            
    def contents(self):
        return deep_convert_dict(self._contents)

    def rowCount(self, index=QModelIndex()):
        return len(self._contents)

    def roleNames(self):
        return {
            self.key_role: b"key",
            self.contents_role: b"contents"
        }

    def set_nested(self, path, value):
        dic = self._contents
        for key in path[:-1]:
            dic = dic.setdefault(key, {})
        if value is None:
            del(dic[path[-1]])
        else:
            if not isinstance(dic, dict):
                # need to have a dict to set value
                # this is false if the element was something else,
                # such as a string
                dic = self.set_nested(path[:-1], {})
            dic[path[-1]] = value
            # return value should only be used in the above case
            # where not isinstance(dic, dict)
            return dic[path[-1]]
    
    def shallow(self):
        return self._shallow
        
    def setShallow(self, value):
        if self._shallow == value:
            return
        self._shallow = value
        self.shallowChanged.emit(value)

    pathChanged = pyqtSignal()
    includeHelpersChanged = pyqtSignal()
    statusChanged = pyqtSignal()
    shallowChanged = pyqtSignal()
    contentsChanged = pyqtSignal()

    path = pyqtProperty(str, path, setPath, notify=pathChanged)
    includeHelpers = pyqtProperty(bool, includeHelpers, setIncludeHelpers, notify=includeHelpersChanged)
    status = pyqtProperty(int, status, setStatus, notify=statusChanged)
    shallow = pyqtProperty(bool, shallow, setShallow, notify=shallowChanged)
    contents = pyqtProperty(QVariant, contents, notify=contentsChanged)

    put_received = pyqtSignal(["QVariant", "QVariant"], name="putReceived", arguments=["path", "data"])
    patch_received = pyqtSignal(["QVariant", "QVariant"], name="patchReceived", arguments=["path", "data"])

class Clipboard(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(str)
    def setText(self, text):
        QApplication.clipboard().setText(text)


class Pyrebase(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(str, name="buildUrl", result=str)
    def build_url(self, path):
        return expipe.io.core.db.child(path).build_request_url(expipe.io.core.user["idToken"])

pyrebase_static = Pyrebase()

def pyrebase_instance(engine, scriptEngine):
    return pyrebase_static

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


def main():
    app = QApplication(sys.argv)
    qmlRegisterType(EventSource, "ExpipeBrowser", 1, 0, "EventSource")
    qmlRegisterSingletonType(Pyrebase, "ExpipeBrowser", 1, 0, "Pyrebase", pyrebase_instance)
    qmlRegisterType(Clipboard, "ExpipeBrowser", 1, 0, "Clipboard")

    QApplication.setOrganizationName("Cinpla")
    QApplication.setApplicationName("Expipe Browser")
#    QtWebEngine.initialize()
    engine = QQmlApplicationEngine()
    engine.setNetworkAccessManagerFactory(NetworkAccessManagerFactory())
    engine.load(QUrl("qrc:/main.qml"))

    return app.exec_()
            

if __name__ == "__main__":
    sys.exit(main())
