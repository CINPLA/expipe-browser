#include "eventsource.h"
#include <QDebug>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>

EventSource::EventSource(QObject *parent) :
    QObject(parent),
    m_manager(this)
{
    connect(&m_manager, &QNetworkAccessManager::finished, this, &EventSource::processReply);
}

QUrl EventSource::url() const
{
    return m_url;
}

void EventSource::setUrl(QUrl url)
{
    if (m_url == url)
        return;

    m_url = url;
    reconnect();
    emit urlChanged(url);
}

void EventSource::reconnect()
{
    QNetworkRequest request(m_url);
    request.setRawHeader("Accept", "text/event-stream");
    QNetworkReply *reply = m_manager.get(request);
    connect(reply, &QNetworkReply::readyRead, this, &EventSource::processReadyRead);
    connect(reply, &QNetworkReply::finished, this, &EventSource::processFinished);
}

void EventSource::processReply(QNetworkReply *reply)
{
    qDebug() << "------------------ GOT MANAGER REPLY ----------------";
    qDebug() << reply->readAll();
    qDebug() << "------------------ END MANAGER REPLY ----------------";
}


void EventSource::processReadyRead()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if(reply) {
        QString eventLine = reply->readLine();
        if(eventLine.startsWith("event:")) {
            eventLine.replace(QRegularExpression("^event:\s*"), "");
            QString eventType = eventLine.trimmed();
            QString dataLine = reply->readLine();
            if(dataLine.startsWith("data:")) {
                dataLine.replace(QRegularExpression("^data:\s*"), "");
                QString data = dataLine.trimmed();
                eventReceived(eventType, data);
            } else {
                qDebug() << "ERROR: Got corrupted data line:" << dataLine;
            }
        } else {
            qDebug() << "ERROR: Got corrupted event line:" << eventLine;
        }
    }
    qDebug() << "Skipping" << reply->readAll();
}


void EventSource::processFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if(reply) {
        qDebug() << "------------------ GOT FINISHED ----------------";
        qDebug() << reply->readAll();
        qDebug() << "------------------ END FINISHED ----------------";
        QUrl url = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
        if(!url.isEmpty()) {
            setUrl(url);
        }
        reply->deleteLater();
    }
}
