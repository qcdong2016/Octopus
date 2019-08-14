#include "myimage.h"

#include <QPainter>
#include <QSize>
#include <QMovie>

MyImage::MyImage()
{
}


MyImage::~MyImage()
{
}

void MyImage::setSource(QString url)
{
    if (_source == url) {
        return;
    }

    _source = url;
    reload();
    emit sourceChanged(url);
}

QString MyImage::source() const
{
    return _source;
}

void MyImage::paint(QPainter *painter) {
    painter->setRenderHints(QPainter::Antialiasing | QPainter::SmoothPixmapTransform);
    QPainterPath path;
    QRect e(0, 0, _sourceSize.width(), _sourceSize.height());
    path.addEllipse(e);
    painter->setClipPath(path);
    painter->drawImage(e, _img);
}

#include "ImageManager.h"

static QImage toGray(const QImage &image)
{
    return image.convertToFormat(QImage::Format_Grayscale8);
}

int random(int _min, int _max)
{
    int temp;
    if (_min > _max)
    {
        temp = _max;
        _max = _min;
        _min = temp;
    }

    return rand() / (double)RAND_MAX *(_max - _min) + _min;
}

QString MyImage::randomAvatar(const QString& text) {
    QColor bgcolor(random(100, 200), random(100, 200), random(100, 200));
    QColor fontcolor(random(100, 200), random(100, 200), random(100, 200));

    const QChar* c = text.unicode();

    return QString("fonts:/"+bgcolor.name() + "/" + fontcolor.name() + "/" + QString(*c));
}

void MyImage::reload() {
    QString url = _source;
    if (url.startsWith("fonts:/")) {
        // fonts:/#ffffff/#ffffff/jim
        url = url.mid(7, url.count()-7);

        int index = url.indexOf('/');
        QString bgcolor = url.mid(0, index);
        url = url.mid(index+1);
        index = url.indexOf('/');
        QString fontcolor = url.mid(0, index);
        QString text = url.mid(index+1);

        _img = QImage(100, 100, QImage::Format_RGB888);
        QPainter painter(&_img);
        QColor bgcolor1(bgcolor);
        painter.fillRect(QRect(0, 0, 100, 100), bgcolor1);

        QFont font(painter.font());
        font.setPixelSize(100- 20);
        painter.setFont(font);
        painter.setPen(QColor(fontcolor));
        painter.drawText(0, 0, 100, 100, Qt::AlignCenter, text);
        painter.end();
    } else {
        _img = QImage();
        if (url.startsWith("qrc:")) {
            url = url.mid(3, url.count() - 3);
        } else if (url.startsWith("cached:/")) {
            url = url.mid(8, url.count() - 8);
            url = ImageManager::cached(url);
        }

        bool ok = _img.load(url);
        qDebug() << ok;
    }
}

void MyImage::setSourceSize(QSize arg)
{
    if (_sourceSize == arg) {
        return;
    }

    _sourceSize = arg;

    if(!_img.isNull())
        reload();

    emit sourceSizeChanged(arg);
}

QSize MyImage::sourceSize() const {
    return _sourceSize;
}





MyImage1::MyImage1()
{
    _img = nullptr;
    _movie = nullptr;
}


MyImage1::~MyImage1()
{
    if (_img != nullptr)
        delete _img;
    if (_movie != nullptr)
        delete _movie;
}

void MyImage1::setSource(QString url)
{
    if (_source == url) {
        return;
    }

    _source = url;
    reload();
    emit sourceChanged(url);
}

QString MyImage1::source() const
{
    return _source;
}

void MyImage1::paint(QPainter *painter) {
    painter->setRenderHints(QPainter::Antialiasing | QPainter::SmoothPixmapTransform);

    QRect e(0, 0, width(), height());
    if (_movie) {
        painter->drawImage(e, _movie->currentImage());
    } else {
        painter->drawImage(e, *_img);
    }
}

void MyImage1::frameChanged(int frame) {
    this->update();
}

#include "ImageManager.h"

void MyImage1::reload() {
    if (_movie != nullptr)
        delete _movie;

    QString url = _source;
    if (url.startsWith("qrc:")) {
        url = url.mid(3, url.count() - 3);
    } else if (url.startsWith("cached:/")) {
        url = url.mid(8, url.count() - 8);
        url = ImageManager::cached(url);
    }

    QImage img(url);

    _imagesize = QSize(img.width(), img.height());
    emit imageSizeChanged(_imagesize);


    if (url.endsWith(".gif")) {
        _movie = new QMovie(url);
        _movie->start();
        connect(_movie, &QMovie::frameChanged, this, &MyImage1::frameChanged, Qt::AutoConnection);
    } else {
        _img = new QImage(img);
    }

//    this->setWidth(_movie->width());
//    this->setHeight(_movie->height());
}
