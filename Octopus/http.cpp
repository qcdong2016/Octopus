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
    clear();
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
    _uploadManager = nullptr;
    _reply = nullptr;
    _file = nullptr;
    _isdownload = true;
}

void Http::clear() {
    if (_file) {
        _file->close();
        _file->deleteLater();
    }
    _file = nullptr;


    if (_reply) {
        _reply->deleteLater();
    }
    _reply = nullptr;

    if (_uploadManager) {
        _uploadManager->deleteLater();
    }
    _uploadManager = nullptr;
}

void Http::upload(QUrl filepath) {

    _isdownload = false;

    _uploadManager = new QNetworkAccessManager(this);
    QString path = filepath.toLocalFile();

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QHttpPart imagePart;
    QString cdh = QString("form-data; name=\"file\"; filename=\"%1\"").arg(getBaseName(path));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, cdh);
    _file = new QFile(path);
    _file->open(QIODevice::ReadOnly);
    imagePart.setBodyDevice(_file);
    _file->setParent(multiPart);
    multiPart->append(imagePart);
    QNetworkRequest request(url());

    QNetworkReply* uploadFileReply = this->_uploadManager->post(request, multiPart);
    multiPart->setParent(uploadFileReply);

    _reply = uploadFileReply;

    connect(uploadFileReply, SIGNAL(finished()), this, SLOT(slot_finished()));
    connect(uploadFileReply, SIGNAL(uploadProgress(qint64, qint64)), this, SLOT(slot_uploadProgress(qint64, qint64)));
    connect(uploadFileReply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(slot_error(QNetworkReply::NetworkError)));
}

void Http::download(QUrl savepath) {
    _savepath = savepath;

    clear();
     _isdownload = true;

    _uploadManager = new QNetworkAccessManager();
    QString path = savepath.toLocalFile();

    _reply = _uploadManager->get(QNetworkRequest(url()));
    connect(_reply, SIGNAL(readyRead()), this, SLOT(slot_readyRead()));
    connect(_reply, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(slot_downloadProgress(qint64, qint64)));
    connect(_reply, SIGNAL(finished()), this, SLOT(slot_finished()));
    connect(_reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(slot_error(QNetworkReply::NetworkError)));

    _file = new QFile(path);
    _file->open(QIODevice::WriteOnly);
    _file->setParent(_reply);
}

void Http::slot_finished() {

    int err = this->_reply->error();
    QByteArray arr = this->_reply->readAll();
    QString str(arr);
    qDebug() << str;

    if (_isdownload && _file != nullptr) {
        _file->flush();
    }

    clear();
    if (err == QNetworkReply::NoError) {
        emit finished();
    } else {
        emit error();
    }

}

void Http::slot_uploadProgress(qint64 send, qint64 total) {
    emit uploadProgress(send, total);
}

void Http::slot_downloadProgress(qint64 send, qint64 total) {
    emit downloadProgress(send, total);
}

void Http::slot_error(QNetworkReply::NetworkError) {
    int err = this->_reply->error();
    QByteArray arr = this->_reply->readAll();
    QString str(arr);
    qDebug() << err<< " " << str;

    clear();
    emit error();
}

void Http::slot_readyRead() {
    if (_file) {
        _file->write(_reply->readAll());
    }
}


