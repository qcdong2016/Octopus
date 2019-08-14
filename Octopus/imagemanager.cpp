#include "imagemanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QBuffer>
#include <QCryptographicHash>

static ImageManager _instance;

ImageManager::ImageManager(QObject *parent) : QObject(parent)
{

}

ImageManager* ImageManager::instace() {
    return &_instance;
}

QSharedPointer<ImageInfo> ImageManager::getImage(const QString& imagePath) {
    ImageInfo* info  = new ImageInfo();
    info->filePath = imagePath;

    QString realPath = imagePath;
    if (realPath.startsWith("qrc:")) {
        realPath = realPath.mid(3, realPath.count() - 3);
    }

    info->image.load(realPath);

    QSharedPointer<ImageInfo> r(info);

    _images.push_back(r);

    return r;
}

QSharedPointer<ImageInfo> ImageManager::addImage(QImage img) {
    ImageInfo* info  = new ImageInfo();
    info->image = img;

    QByteArray array;
    QBuffer buffer(&array);
    info->image.save(&buffer, "PNG");

    QByteArray arr = QCryptographicHash::hash(buffer.data(), QCryptographicHash::Md5);

    QSharedPointer<ImageInfo> r(info);

    r->filePath = saveFile(arr.toHex() + ".png", buffer.data());

    _images.push_back(r);

    return r;
}

QString ImageManager::cached(const QString& fileName) {
    const QString cachepath = ".Octopus/imagecaches";
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::HomeLocation));
    dir.setPath( dir.filePath(cachepath));
    return dir.filePath(fileName);
}

QString ImageManager::saveFile(const QString& fileName, const QByteArray& data) {
    const QString cachepath = ".Octopus/imagecaches";
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::HomeLocation));

    bool ok = dir.mkpath(cachepath);

    dir.setPath(dir.filePath(cachepath));

    QString filePath = dir.filePath(fileName);

    QFile file(filePath);

    ok = file.open(QIODevice::WriteOnly);

    file.write(data);
    file.close();

    return filePath;
}

QString getExt(const QString& fileName) {
    int index = fileName.lastIndexOf('.');
    return fileName.mid(index);
}

QString ImageManager::cacheFile(const QString& fileName) {

    QUrl url(fileName);
    QString path = url.toLocalFile();
    QFile file(path);

    bool ok = file.open(QIODevice::ReadOnly);

    QByteArray d = file.readAll();
    file.close();

    QByteArray md5 = QCryptographicHash::hash(d, QCryptographicHash::Md5);

    return saveFile(md5.toHex() + "." + getExt(fileName), d);
}
