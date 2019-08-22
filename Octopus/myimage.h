#ifndef MYIMAGE_H
#define MYIMAGE_H

#include <QQuickPaintedItem>
#include <QImage>

class MyImage : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QSize sourceSize READ sourceSize WRITE setSourceSize NOTIFY sourceSizeChanged)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool displayGray READ displayGray WRITE setDisplayGray NOTIFY displayGrayChanged)

signals:
    void sourceSizeChanged(QSize arg);
    void sourceChanged(QString arg);
    void displayGrayChanged(bool arg);

public:

    void setSource(QString arg);
    void setSourceSize(QSize arg);
    void setDisplayGray(bool arg);

    static QString randomAvatar(const QString& text);

public:
    MyImage();
    ~MyImage();

    virtual void paint(QPainter *painter);
    QSize sourceSize() const;
    QString source() const;
    bool displayGray() const;

    void reload();

private:
    QString _source;
    QImage _img;
    QSize _sourceSize;
    bool _displayGray;
    bool _shouldReload;
};

class MyImage1 : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QSize imageSize READ imageSize NOTIFY imageSizeChanged)


signals:
    void sourceChanged(QString arg);
    void imageSizeChanged(QSize sz);

public:
    void setSource(QString arg);
    QSize imageSize() { return _imagesize; }

public:
    MyImage1();
    ~MyImage1();

    virtual void paint(QPainter *painter);
    QString source() const;

    void reload();

private slots:
    void frameChanged(int frame);

private:
    QString _source;
    QSize _imagesize;
    QImage* _img;
    QMovie* _movie;
};

#include <QPixmap>

class MyFileIcon : public QQuickPaintedItem {
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)

signals:
    void sourceChanged();
public:
    void setSource(QUrl arg);
public:
    MyFileIcon();
    ~MyFileIcon();

    virtual void paint(QPainter *painter);
    QUrl source() const;

public slots:
    void requestReload();
    void reload();

private:
    QUrl _source;
    QPixmap _img;
    bool _shouldReload;
};

#endif // MYIMAGE_H
