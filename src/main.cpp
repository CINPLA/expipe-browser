#include "cachemodel.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlError>
#include <QtWebEngine/QtWebEngine>

int main(int argc, char *argv[])
{
    //    qmlRegisterType<ExperimentModel>("CinplaBrowser", 1, 0, "ExperimentModel");
    qmlRegisterType<SqlQueryModel>("ExpipeBrowser", 1, 0, "SqlQueryModel");

    QGuiApplication::setOrganizationName("Cinpla");
    QGuiApplication::setApplicationName("Expipe Browser");

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("/media/norstore/server-cache.db");
    if(!db.open()) {
        qDebug() << db.lastError();
        exit(0);
    }

    QApplication app(argc, argv);

    QtWebEngine::initialize();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

