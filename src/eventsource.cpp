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
}


void EventSource::processReadyRead()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if(reply) {
        QString contents = reply->readAll().trimmed();
        QStringList lines = contents.split("\n");
        if(lines.count() < 2) {
            qDebug() << "ERROR: Too few lines in event!" << lines;
            qDebug() << "Contents:" << contents;
            return;
        }
        QString eventLine = lines[0];
        QString dataLine = lines[1];
        if(eventLine.startsWith("event:") && dataLine.startsWith("data:")) {
            eventLine.replace(QRegularExpression("^event:\\s*"), "");
            QString eventType = eventLine.trimmed();
            dataLine.replace(QRegularExpression("^data:\\s*"), "");
            QString data = dataLine.trimmed();
            eventReceived(eventType, data);
        } else {
            qDebug() << "ERROR: Got corrupted event line";
            qDebug() << "Contents:" << contents;
            return;
        }
    }
}


void EventSource::processFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if(reply) {
        QUrl url = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
        if(!url.isEmpty()) {
            setUrl(url);
        }
        reply->deleteLater();
    }
}
