#include "cachemodel.h"
#include "eventsource.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include <QSqlDatabase>
#include <QSqlError>
#include <QtWebEngine/QtWebEngine>

class MyNAMFactory : public QQmlNetworkAccessManagerFactory
{
public:
    virtual QNetworkAccessManager *create(QObject *parent);
};

QNetworkAccessManager *MyNAMFactory::create(QObject *parent)
{
    QNetworkAccessManager *nam = new QNetworkAccessManager(parent);
    auto *cache = new QNetworkDiskCache(parent);
    cache->setCacheDirectory("/tmp/lol/");
    nam->setCache(cache);
    return nam;
}

//int main(int argc, char **argv)
//{
//    QGuiApplication app(argc, argv);
//    QQuickView view;
//    view.engine()->setNetworkAccessManagerFactory(new MyNAMFactory);
//    view.setSource(QUrl("qrc:///main.qml"));
//    view.show();

//    return app.exec();
//}

int main(int argc, char *argv[])
{
    //    qmlRegisterType<ExperimentModel>("CinplaBrowser", 1, 0, "ExperimentModel");
    qmlRegisterType<SqlQueryModel>("ExpipeBrowser", 1, 0, "SqlQueryModel");
    qmlRegisterType<EventSource>("ExpipeBrowser", 1, 0, "EventSource");

    QGuiApplication::setOrganizationName("Cinpla");
    QGuiApplication::setApplicationName("Expipe Browser");

//    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
//    db.setDatabaseName("/media/norstore/server-cache.db");
//    if(!db.open()) {
//        qDebug() << db.lastError();
//        exit(0);
//    }

    QApplication app(argc, argv);

    QtWebEngine::initialize();

    QQmlApplicationEngine engine;
    engine.setNetworkAccessManagerFactory(new MyNAMFactory);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

