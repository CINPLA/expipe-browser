#include "experimentmodel.h"

#include <h5cpp/file.h>

#include <QDir>
#include <QFileInfoList>
#include <iostream>

using namespace elegant::hdf5;
using namespace std;

ExperimentModel::ExperimentModel()
{
    QFileInfoList list = dirsAtLevel("/media/norstore/norstore_osl/projects/NS9048K/storage", 2);
    for (const QFileInfo& folderInfo : list) {
        QDir dir(folderInfo.absoluteFilePath());
        dir.setFilter(QDir::Files| QDir::Hidden | QDir::NoSymLinks);
        dir.setSorting(QDir::Size | QDir::Reversed);

        QFileInfoList fileList = dir.entryInfoList();
        for (const QFileInfo& fileInfo : fileList) {

            string absolutePath = fileInfo.absoluteFilePath().toStdString();
            cout << absolutePath << endl;
            File file(absolutePath, File::OpenMode::ReadOnly);
            ExperimentInfo e;
            if(file.hasAttribute("experimenter")) {
                e.experimenter = QString::fromStdString(file.attribute("experimenter"));
            }
            if(file.hasKey("rawfile")) {
                Group g = file["rawfile"];
                e.rawPath = QString::fromStdString(g.attribute("filebase"));
                cout << e.rawPath.toStdString() << endl;
            }
            e.filename = fileInfo.fileName();

            QStringList names;
            names << "Mikkel Lepperød" << "Ane Charlotte Christensen" << "Kristian Lensjø";
            QStringList images;
            images << "https://media.licdn.com/media/p/1/005/009/29e/3866099.jpg"
                   << "https://www.mn.uio.no/vrtx/decorating/resources/dist/images/incognito.png"
                   << "http://radionova.no/moss/aad7a0a0-1897-0131-e625-5254007f5914-medium.jpg";
            int randval = qrand() % names.size();

            Group experimenter = file["experimenter"];

            string experimenterString = experimenter.attribute("name");
            string emailString = experimenter.attribute("email");
            e.experimenter = QString::fromStdString(experimenterString);
            e.email = QString::fromStdString(emailString);

            m_experiments.append(e);
        }
    }
}

QFileInfoList ExperimentModel::dirsAtLevel(QString dirname, int level)
{
    QFileInfoList fullList;
    QDir dir(dirname);
    dir.setFilter(QDir::Dirs | QDir::Hidden | QDir::NoSymLinks | QDir::NoDotAndDotDot);
    dir.setSorting(QDir::Size | QDir::Reversed);

    QFileInfoList list = dir.entryInfoList();
    for (const QFileInfo& folderInfo : list) {
        if(level == 0) {
            fullList.append(folderInfo);
        } else {
            QFileInfoList other = dirsAtLevel(folderInfo.absoluteFilePath(), level-1);
            fullList += other;
        }
    }
    return fullList;
}

int ExperimentModel::rowCount(const QModelIndex &parent) const
{
    m_experiments.size();
}

int ExperimentModel::columnCount(const QModelIndex &parent) const
{
    return 3;
}

QVariant ExperimentModel::data(const QModelIndex &index, int role) const
{
    const ExperimentInfo &experiment = m_experiments.at(index.row());
    QVariant returnValue;
    switch(role) {
    case 0:
        return QVariant(experiment.rawPath);
        break;
    case 1:
        returnValue = experiment.experimenter;
        break;
    case 2:
        returnValue = QVariant("2015-10-24 10:12");
        break;
    case 3:
        returnValue = experiment.filename;
        break;
    case 4:
        returnValue = experiment.email;
        break;
    default:
        returnValue = QVariant();
        break;
    }
    return returnValue;
}

QHash<int, QByteArray> ExperimentModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[0] = "rawpath";
    roles[1] = "experimenter";
    roles[2] = "datetime";
    roles[3] = "filename";
    roles[4] = "email";
    return roles;
}

