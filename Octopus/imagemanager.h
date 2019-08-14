#ifndef IMAGEMANAGER_H
#define IMAGEMANAGER_H

#include <QObject>
#include <QImage>
#include <QSharedPointer>
#include <QList>

class ImageInfo : public QObject {
    Q_OBJECT

public:
    QImage image;
    QString filePath;
};

class ImageManager : public QObject
{
    Q_OBJECT
public:
    explicit ImageManager(QObject *parent = nullptr);

    static ImageManager* instace();

    QSharedPointer<ImageInfo> getImage(const QString& imagePath);
    QSharedPointer<ImageInfo> addImage(QImage img);

    static QString saveFile(const QString& fileName, const QByteArray& data);
    static QString cached(const QString& fileName);
    static QString cacheFile(const QString& fileName);

signals:

public slots:

private:

    QList<QSharedPointer<ImageInfo> > _images;
};

#endif // IMAGEMANAGER_H
