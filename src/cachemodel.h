#ifndef CACHEMODEL_H
#define CACHEMODEL_H

#include <QSqlQueryModel>

class SqlQueryModel : public QSqlQueryModel
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)

public:
    explicit SqlQueryModel(QObject *parent = 0);

    void setQuery(const QString &query, const QSqlDatabase &db = QSqlDatabase());
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
    QString query() const;

signals:
    void queryChanged(QString query);

private:
    void generateRoleNames();
    QHash<int, QByteArray> m_roleNames;
    QString m_query;
};

#endif // CACHEMODEL_H
