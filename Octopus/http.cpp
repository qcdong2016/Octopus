#include "http.h"
#include <QHttpMultiPart>
#include <QNetworkRequest>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>


QString getBaseName(QString filepath) {
    int index = filepath.lastIndexOf("/");
    return filepath.mid(index+1);
}

Http::~Http() {
    delete _uploadManager;
    if (_reply) {
        delete _reply;
    }
}

QUrl Http::url() {
    return _url;
}

void Http::setUrl(QUrl url) {
    _url = url;
    emit urlChanged(url);
}

Http::Http(QObject *parent) : QObject(parent)
{
    _uploadManager = new QNetworkAccessManager(this);
    _reply = nullptr;
}

void Http::upload(QUrl filepath) {

    QString path = filepath.toLocalFile();

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QHttpPart imagePart;
    QString cdh = QString("form-data; name=\"file\"; filename=\"%1\"").arg(getBaseName(path));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, cdh);
    QFile* imgFile = new QFile(path);
    imgFile->open(QIODevice::ReadOnly);
    imagePart.setBodyDevice(imgFile);
    imgFile->setParent(multiPart);
    multiPart->append(imagePart);
    QNetworkRequest request(url());

    QNetworkReply* uploadFileReply = this->_uploadManager->post(request, multiPart);
    multiPart->setParent(uploadFileReply);

    _reply = uploadFileReply;

    connect(uploadFileReply, SIGNAL(finished()), this, SLOT(slot_finished()));
    connect(uploadFileReply, SIGNAL(uploadProgress(qint64, qint64)), this, SLOT(slot_uploadProgress(qint64, qint64)));
    connect(uploadFileReply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(slot_error(QNetworkReply::NetworkError)));
}


void Http::slot_finished() {
    int err = this->_reply->error();
    QByteArray arr = this->_reply->readAll();
    QString str(arr);

    qDebug() << str;
    if (err == QNetworkReply::NoError) {
        emit finished();
    } else {
        emit error();
    }
}

void Http::slot_uploadProgress(qint64 send, qint64 total) {
    emit uploadProgress(send, total);
}

void Http::slot_error(QNetworkReply::NetworkError) {
    emit error();
}


