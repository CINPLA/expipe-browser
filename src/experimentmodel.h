#ifndef EXPERIMENTMODEL_H
#define EXPERIMENTMODEL_H

#include <QAbstractTableModel>
#include <QDateTime>
#include <QFileInfoList>
#include <QQuickItem>

struct ExperimentInfo
{
    QString experimenter;
    QString email;
    QString rawPath;
    QDateTime datetime;
    QString filename;
    QString image;
};

class ExperimentModel : public QAbstractTableModel
{
    Q_OBJECT
public:
    ExperimentModel();

    int rowCount(const QModelIndex &parent) const override;
    int columnCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const;

signals:

public slots:

private:
    int m_rowCount = 0;
    int m_columnCount = 0;
    QFileInfoList dirsAtLevel(QString dirname, int level);
    QList<ExperimentInfo> m_experiments;
};

#endif // EXPERIMENTMODEL_H
