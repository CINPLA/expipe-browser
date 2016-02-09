#include <QApplication>
#include <QQmlApplicationEngine>

#include "experimentmodel.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<ExperimentModel>("CinplaBrowser", 1, 0, "ExperimentModel");

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

