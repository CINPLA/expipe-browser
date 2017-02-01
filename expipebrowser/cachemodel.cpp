#include "cachemodel.h"

#include <QSqlRecord>
#include <QSqlField>
#include <QDebug>

SqlQueryModel::SqlQueryModel(QObject *parent) :
    QSqlQueryModel(parent)
{
}

void SqlQueryModel::setQuery(const QString &query, const QSqlDatabase &db)
{
    if(m_query == query) {
        return;
    }
    m_query = query;
    QSqlQueryModel::setQuery(query, db);
    generateRoleNames();
    emit queryChanged(m_query);
}

void SqlQueryModel::generateRoleNames()
{
    m_roleNames.clear();
    for( int i = 0; i < record().count(); i ++) {
        m_roleNames.insert(Qt::UserRole + i + 1, record().fieldName(i).toUtf8());
    }
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if(role < Qt::UserRole) {
        value = QSqlQueryModel::data(index, role);
    }
    else {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

QHash<int, QByteArray> SqlQueryModel::roleNames() const {
    return m_roleNames;
}

QString SqlQueryModel::query() const
{
    return m_query;
}
