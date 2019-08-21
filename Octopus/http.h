#ifndef HTTP_H
#define HTTP_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class Http : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
public:
    explicit Http(QObject *parent = nullptr);
    ~Http();

    QUrl url();

    Q_INVOKABLE void upload(QUrl filepath);

signals:
    void urlChanged(QUrl url);

    void finished();
    void uploadProgress(qint64, qint64);
    void error();

public slots:
    void setUrl(QUrl url);

private slots:
    void slot_finished();
    void slot_uploadProgress(qint64, qint64);
    void slot_error(QNetworkReply::NetworkError);

private:
    QUrl _url;

    QNetworkAccessManager *_uploadManager;
    QNetworkReply* _reply;
};

#endif // HTTP_H
