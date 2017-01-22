#ifndef EVENTSOURCE_H
#define EVENTSOURCE_H

#include <QObject>
#include <QUrl>
#include <QNetworkAccessManager>

class EventSource : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    explicit EventSource(QObject *parent = 0);

    QUrl url() const;

    void reconnect();
signals:
    void urlChanged(QUrl url);
    void eventReceived(QString type, QString data);

public slots:
    void setUrl(QUrl url);

private slots:
    void processReply(QNetworkReply* reply);
    void processReadyRead();
    void processFinished();
private:
    QUrl m_url;
    QNetworkAccessManager m_manager;
};

#endif // EVENTSOURCE_H
