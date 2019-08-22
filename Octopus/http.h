#ifndef HTTP_H
#define HTTP_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>

class Http : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
public:
    explicit Http(QObject *parent = nullptr);
    ~Http();

    QUrl url();

    Q_INVOKABLE void upload(QUrl filepath);
    Q_INVOKABLE void download(QUrl savepath);

signals:
    void urlChanged(QUrl url);

    void finished();
    void uploadProgress(qint64, qint64);
    void downloadProgress(qint64, qint64);
    void error();

public slots:
    void setUrl(QUrl url);
    void clear();

private slots:
    void slot_readyRead();
    void slot_finished();
    void slot_uploadProgress(qint64, qint64);
    void slot_error(QNetworkReply::NetworkError);
    void slot_downloadProgress(qint64, qint64);

private:
    QUrl _url;

    QNetworkAccessManager *_uploadManager;
    QNetworkReply* _reply;
    QFile* _file;
    bool _isdownload;
    QUrl _savepath;
};

#endif // HTTP_H
